require 'rubygems'
require 'gosu'

class Macchina
  
  GROUND = 260
  WIDTH = 60
  HEIGHT = 40
  
  def initialize(window)
    @image = Gosu::Image.new(window, "media/car.png", false)
    @window = window
    @x=180
    @y=GROUND
    @vel_y =0
    @vel_x =0
  end
  
  def jump
    @vel_y += 10 if @y == GROUND
  end
  
  def accel_x(direction)
    if direction==:left
      @vel_x -=1
    elsif direction==:right
      @vel_x +=1
    end
  end
  
  def move
    #gravity
    if @y<GROUND
      @vel_y -= 0.5
    elsif @y>GROUND
      @vel_y = 0
      @y=GROUND
    end
    
    #deceleration
    @vel_x -= 0.5 if @vel_x > 0
    @vel_x += 0.5 if @vel_x < 0
    
    #final
    @y -= @vel_y #il mio asse y e al contrario
    @x += @vel_x
    
    #border
    @x=0 if @x<0
    max_x = @window.width - 60
    @x=max_x if @x>max_x
  end
  
  def draw
    @image.draw(@x, @y, 3)
  end
  
  def collided?(ostacoli)
    ostacoli.each do |ostacolo|
      if (ostacolo.x < @x && ostacolo.x > @x - WIDTH) and (ostacolo.y <= @y + HEIGHT) then
        unless ostacolo.collided #if not already collided
          ostacolo.collided=true
          return true
        end
      end
    end
    return false
  end
end

class Ostacolo
  attr_reader :x, :y
  attr_accessor :collided
  
  def initialize(window)
    @image = Gosu::Image.new(window, "media/car2.png", false)
    @window = window
    @y=260
    @x=@window.width
    @vel_x = -1 - rand(4)
    @collided = false
  end
  
  def move
    if @x<=0 then
      @x = @window.width
      @collided=false #resetto @collided quando respawna
    end
    @x+= @vel_x
  end
  
  def draw
    @image.draw(@x, @y, 3)
  end
end

class GameWindow < Gosu::Window
  def initialize
    super(640, 480, true)
    self.caption = "Prova Macchina!"
    load_level(self)
  end
  
  def load_level(window)
    @background_image = Gosu::Image.new(window, "media/erba.png", true)
    @macchina = Macchina.new(window)
    @font = Gosu::Font.new(window, Gosu::default_font_name, 20)
    @ostacoli = Array.new
    @ostacoli << Ostacolo.new(window)
    @last_time_scored = Time.now
    @punteggio = 0
    @ultimo_aumento_difficolta = 0
    @vite = 3
    @playing = true
  end
  
  def update
    if @playing
      
      if Time.now - @last_time_scored > 1
        @punteggio +=1
        @last_time_scored = Time.now
      end
      
      if @macchina.collided?(@ostacoli) then
        @vite-=1
        @playing = false if @vite<=0
      end
      
      if @punteggio - @ultimo_aumento_difficolta >= 5 then
        @ostacoli << Ostacolo.new(self)
        @ultimo_aumento_difficolta = @punteggio
      end
      
      @macchina.move
      
      if button_down? Gosu::KbUp then
        @macchina.jump
      end
      
      if button_down? Gosu::KbLeft then
        @macchina.accel_x(:left)
      end
      
      if button_down? Gosu::KbRight then
        @macchina.accel_x(:right)
      end
      
      @ostacoli.each {|ostacolo| ostacolo.move}
      
    else #game over
      if button_down? Gosu::KbR then
        load_level(self)
      end
    end
  end

  def draw
    if @playing then
      @background_image.draw(0, 0, 0)
      @macchina.draw
      @ostacoli.each {|ostacolo| ostacolo.draw}
      @font.draw("Vite Rimaste: #{@vite}", 10, 10, 5, 1.0, 1.0, 0xffffff00)
      @font.draw("Punteggio: #{@punteggio}", 10, 30, 5, 1.0, 1.0, 0xffffff00)
    else
      @background_image.draw(0, 0, 0)
      @font.draw("Game Over", 10, 180, 5, 5, 5, 0xffffff00)
      @font.draw("Punteggio: #{@punteggio}", 20, 250, 5, 2, 2, 0xffffff00)
      @font.draw("Premi R per rifare, o ESC per uscire", 20, 370, 5, 2, 2, 0xffffff00)
    end
  end

  def button_down(id)
    if id == Gosu::KbEscape then
      close
    end
  end
end

window = GameWindow.new
window.show