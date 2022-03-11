require "gosu" 
SCREEN_WIDTH = 800
SCREEN_HEIGHT = 800

module ZOrder
    BACKGROUND, BULLET ,OBS, PLAYER, UI = *0..4
end

# attributes for player 1

class Ship_1
    attr_accessor :x, :y, :vel_x, :vel_y, :image, :angle

    def initialize
        @image = Gosu::Image.new("media/spaceship.png")
        @vel_x = @vel_y = 3.5
        @x = @y = @angle = 0.0
    end
end

# attributes for player 2

class Ship_2
    attr_accessor :x, :y, :vel_x, :vel_y, :image, :angle

    def initialize
        @image = Gosu::Image.new("media/spaceship2.png")
        @vel_x = @vel_y = 3.5
        @x = @y = @angle = 0.0
    end
end

# attributes for asteroids

class Obstacles
    attr_accessor :x, :y, :spd, :image, :hit, :angle, :index, :turn
    def initialize
        @image = Gosu::Image.new("media/rock.png")
        @spd = rand(5..10)
        case rand(2) 
            when 0
                @x = -30
                @angle = rand(-15..15)
            when 1
                @x = SCREEN_WIDTH + 30
                @angle = rand(-195..-165)
        end
        @y = rand(1.. (SCREEN_HEIGHT / 2))
        @hit = false
        @index = 0
        @turn = rand(5..15)
    end
end

# attributes for bullets

class Bullet 
    attr_accessor :x, :y, :bullet_image, :hit, :type
    
    def initialize(x, y, type)
        @bullet_image = Gosu::Image.new("media/bullet.png")
        @x = x
        @y = y
        @hit = false
        @type = type
    end
end

# create movements for players

def move_left ship
    if ship.x > (ship.image.width / 2).to_f()
        ship.x -= ship.vel_x 
    end
end

def move_right ship
    if ship.x < (SCREEN_WIDTH - (ship.image.width / 2)).to_f()
        ship.x += ship.vel_x
    end
end

def move_up ship
    if ship.y > (ship.image.height / 2).to_f()
        ship.y -= ship.vel_y
    end
end

def move_down ship
    if ship.y < (SCREEN_HEIGHT - (ship.image.height / 2)).to_f()
        ship.y += ship.vel_y
    end
end

# print out the images for each player's ship

def draw_ship ship
  ship.image.draw_rot(ship.x, ship.y, ZOrder::PLAYER, ship.angle)
end

# set the initialized location for each player's ship

def warp(ship, x, y)
    ship.x = x
    ship.y = y
end

# print out the images for asteroids and create their spins

def draw_obs(obstacles)
    obstacles.index += obstacles.turn
    obstacles.image.draw_rot(obstacles.x, obstacles.y, ZOrder::OBS, obstacles.index)
end

# create movements for asteroids

def move_obs(obstacles)
    obstacles.x += obstacles.spd * Math.cos(obstacles.angle * Math::PI / 180)
    obstacles.y += obstacles.spd * Math.sin(obstacles.angle * Math::PI / 180)
end    

# print out the images for bullets

def draw_bullet(bullet)
    bullet.bullet_image.draw_rot(bullet.x + 15.0, bullet.y - 25.0, ZOrder::BULLET, 0)
end

# create movements for bullets

def move_bullet(bullet)
    bullet.y -= 10
end

class Game < (Example rescue Gosu::Window)

# initialize the necessary elements

    def initialize
        super SCREEN_WIDTH, SCREEN_HEIGHT
        self.caption = "Shooting Game"
        @background = Gosu::Image.new("media/space.jpg")
        @player1 = Ship_1.new
        @player2 = Ship_2.new
        @obstacles = Array.new
        @bullets = Array.new
        @font = Gosu::Font.new(30)
        warp(@player1, (SCREEN_WIDTH / 3), (SCREEN_HEIGHT - 120))
        warp(@player2, (SCREEN_WIDTH / 3 * 2), (SCREEN_HEIGHT - 120))
        @reload_1 = 5
        @reload_2 = 5
        @score1 = 0
        @score2 = 0 
    end

# receive input to update the game state

    def update
        if Gosu.button_down? Gosu::KB_LEFT
            move_left @player2
        end
        if Gosu.button_down? Gosu::KB_RIGHT
            move_right @player2
        end
        if Gosu.button_down? Gosu::KB_UP
            move_up @player2
        end
        if Gosu.button_down? Gosu::KB_DOWN
            move_down @player2
        end
        if button_down?(4)
            move_left @player1
        end
        if button_down?(7)
            move_right @player1
        end
        if button_down?(26)
            move_up @player1
        end
        if button_down?(22)
            move_down @player1
        end
    end

# create movements for all elements

    def draw

# draw the background of the game

        @background.draw(0, 0, ZOrder::BACKGROUND)
        draw_ship @player1
        draw_ship @player2
        
# ensure that there are always 10 asterroids on the screen

        if @obstacles.length < 10
            @obstacles.push(Obstacles.new)     
        end

# pass in each player's location to shoot out bullets

        @obstacles.each { |obstacles|draw_obs obstacles}
        @obstacles.each { |obstacles|move_obs obstacles}
        if button_down?(25) #V = 25, M = 16
            @reload_1 -= 1
            if @reload_1 < 0
                @reload_1 = 5
            end
            if @reload_1 == 1
                @bullets.push(Bullet.new(@player1.x, @player1.y, 1))
            end
        end
        if button_down?(16) #V = 25, M = 16
            @reload_2 -= 1
            if @reload_2 < 0
                @reload_2 = 5
            end
            if @reload_2 == 1
                @bullets.push(Bullet.new(@player2.x, @player2.y, 2))
            end
        end

# destroy both the bullet and the asteroid if their locations match

        @bullets.each { |bullet| draw_bullet bullet}
        @bullets.each { |bullet| move_bullet bullet}
        @bullets.each do |bullet|
            @obstacles.each do |obstacles|
                if ((obstacles.x - (obstacles.image.width / 2)) < bullet.x && (obstacles.x + (obstacles.image.width / 2)) > bullet.x) && ((obstacles.y - (obstacles.image.height / 2)) < bullet.y && (obstacles.y + (obstacles.image.height / 2)) > bullet.y)
                    bullet.hit = true
                    obstacles.hit = true
                end
            end
        end 
        @bullets.each do |bullet|
            if bullet.hit == true
                case bullet.type
                    when 1
                        @score1 += 1
                    when 2
                        @score2 += 1
                end
            end
        end
        @bullets.reject! do |bullet|
            (bullet.hit == true) || (bullet.y < 0)
        end
        @obstacles.reject! do |obstacles|
            (obstacles.hit == true) || ( (obstacles.x <= -60) || (obstacles.x >= (SCREEN_WIDTH + 60)) )
        end
        
# print out the winner and prompt the user to exit
    
        if @score1 >= 100
            @font.draw_text("Player 1 won", 310, 200, ZOrder::UI, 1, 1, Gosu::Color::WHITE)
            @font.draw_text("Press Esc to exit", 310, 250, ZOrder::UI, 1, 1, Gosu::Color::WHITE)
        elsif @score2 >= 100
            @font.draw_text("Player 2 won", 310, 200, ZOrder::UI, 1, 1, Gosu::Color::WHITE)
            @font.draw_text("Press Esc to exit", 310, 250, ZOrder::UI, 1, 1, Gosu::Color::WHITE)
        end
        @font.draw_text("Player 1: #{@score1}", 20, 50, ZOrder::UI, 1, 1, Gosu::Color::WHITE)
        @font.draw_text("Player 2: #{@score2}", SCREEN_WIDTH - 155, 50, ZOrder::UI, 1, 1, Gosu::Color::WHITE)
        @font.draw_text("Hit 100 first to win", 295, 20, ZOrder::UI, 1, 1, Gosu::Color::WHITE)
    end

# close the program    

    def button_down(id)
        if id == Gosu::KB_ESCAPE
            close
        end
    end
end

Game.new.show if __FILE__ == $0