### Toget gosu run: gem install gosu


require 'gosu'

$is_demo = false
$is_win = false
class Pearl
  attr_reader :x, :y,:weight
  def initialize(win,n,y,color,rand_col)
    @x = (840/9)*n - (840/9)
    @y = y
    @image = Gosu::Image.new(win,"media/#{color.downcase}_pearl.png",:tileable => true)
    ##set weight
     if rand_col == color
      @weight = (rand + rand).round(2)
    else
      @weight = 1
    end
  end
  ##make pearls drag and drop
  def move(x,y,spots,other_pearls)
    if Gosu.button_down? Gosu::MsLeft
      if x >= @x - 10 && x <= @x + 60 && y >= @y - 10 && y <= @y + 60
        @x = x - 33
        @y = y - 33
      end
    end
    ###moves pearl if another pear is in the same place
    pearl_distances = []
    other_pearls.each do |pearl|
      if Gosu.distance(@x, @y, pearl.x, pearl.y) == 0
        @y += 50
      end
    end
    # spots.select!{|spot| spot.spot_weight != false }
    @distances = []
    spots.each do |spot|
      @distances << [spot,Gosu.distance(@x, @y, spot.spot_x, spot.spot_y)]
    end
    ### moves to closest sport if spot is empty
    spot = @distances.to_h.sort_by{|k,v| v}.first.first
    if !Gosu.button_down? Gosu::MsLeft
      @x = spot.spot_x if spot.spot_weight == 0
      @y = spot.spot_y if spot.spot_weight == 0
    end
  end
  def draw(font)
      ###draws pearl
    @image.draw(@x,@y,0,scale_x = 0.5, scale_y = 0.5)
    ### if demo show peal weight
    if $is_demo
      @font = font
      @font.draw_text(@weight, @x + 50, @y + 50, 4, 1.0, 1.0, Gosu::Color::BLACK)
    end
    end
end


class Scale
  attr_accessor :x, :y
  def initialize(x,y,z)
    @image =  Gosu::Image.new("media/tray.png", :tileable => true)
    @x = x
    @y = y
    @z = z
  end
  def draw()
    @image.draw(@x,@y,@z)
  end
end

class Crossbar
  attr_accessor :r
  def initialize(r)
    @image = Gosu::Image.new("media/cross_bar.png", :tileable => true)
    @r = r
  end
  def draw
    @image.draw_rot(840/2, 480/2-@image.height/2-85, 4,@r)
  end
end



class Spot
  attr_reader :spot_x, :spot_y, :spot_weight, :type
  def initialize(x,y,spot_weight,type)
    @spot_x = x
    @spot_y = y
    @type = type
    @spot_weight = spot_weight
  end

  # def check(pearls)
  #   ###grabs weight and distance from gem per pearl
  #   @pearls = pearls
  #   @pearls_info = []
  #   @pearls.each do |pearl|
  #     @pearls_info << [pearl.weight, Gosu.distance(@spot_x, @spot_y, pearl.x, pearl.y).round]
  #   end
  #
  #   pearl_info = @pearls_info.to_h.sort_by{|k,v| v}.first
  #   @pearl_distance = pearl_info[1]
  #   pearl_weight = pearl_info[0]
  #
  #     ##sets spot weight to pearl weight if pearl is in spot
  #   if @pearl_distance == 0
  #     @spot_weight = pearl_weight
  #   else
  #     @spot_weight = 0
  #   end
  # end


  def check(pearls)
    @empty = true
    @pearls = pearls
    distances = []
    @pearls.each do |pearl|
      dis = Gosu.distance(@spot_x, @spot_y, pearl.x, pearl.y)
      distances << dis
      if dis < 10
        @spot_weight = pearl.weight
        @empty = false
      end
    end
    if @empty
      @spot_weight = 0
    end
  end

    ###move spots based on weight of each side
  def move(spots,left_tray,right_tray,crossbar_image,test_count)
    ##gets weight of scalse sides
    left = spots.select{|s|s.type == "left"}
    left_weight = left.map{|s| s.spot_weight}.sum
    right = spots.select{|s|s.type == "right"}
    right_weight = right.map{|s| s.spot_weight}.sum
    ##moves scale appropriately by weight
    if Gosu.button_down? Gosu::KbReturn
      if left_weight > right_weight && left_tray.y > 120
        left_tray.y -= 0.2
        right_tray.y += 0.2
        crossbar_image.r -= 0.05
          @spot_y += 6 if @type == "left"
          @spot_y -= 6 if @type == "right"
      elsif right_weight > left_weight && left_tray.y < 183
        left_tray.y += 0.2
        right_tray.y -= 0.2
        crossbar_image.r += 0.05
          @spot_y -= 6 if @type == "left"
          @spot_y += 6 if @type == "right"
      elsif left_tray.y > right_tray.y && left_tray.y >= 119
        left_tray.y -= 0.2
        right_tray.y += 0.2
        crossbar_image.r -= 0.05
          @spot_y += 6 if @type == "left"
          @spot_y -= 6 if @type == "right"
      elsif right_tray.y > left_tray.y && left_tray.y <= 184
        left_tray.y += 0.2
        right_tray.y -= 0.2
        crossbar_image.r += 0.05
          @spot_y -= 6 if @type == "left"
          @spot_y += 6 if @type == "right"
      end
    end
    if Gosu.button_down? Gosu::KB_R
      left_tray.y = 153
      right_tray.y = 153
      crossbar_image.r = 0
        @spot_y = 6 if @type == "left"
        @spot_y = 6 if @type == "right"
    end
  end

  def is_win?(win_spot)
    if Gosu.button_down?(Gosu::KbReturn)
      if win_spot.spot_weight > 0 && win_spot.spot_weight != 1
        $is_win = true
      else
        $is_win = false
      end
    end
  end
  def draw(font)
    @font = font
    # @font.draw_text(@spot_weight , @spot_x, @spot_y, 4, 1.0, 1.0, Gosu::Color::BLACK)
    @font.draw_text(@spot_weight , @spot_x, @spot_y, 4, 1.0, 1.0, Gosu::Color::BLACK)
      # @font.draw_text(@pearls_info.map{|p| p[1]} , 0, 30, 4, 1.0, 1.0, Gosu::Color::BLACK)
  end
end

class Tutorial < Gosu::Window
  attr_reader :test_count
  def initialize
    super 840, 480 #, :update_interval => 1000.0
    self.caption = "The Riddle"
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @background_image = Gosu::Image.new("media/blue_stuff.png", :tileable => true)
    @you_win_image = Gosu::Image.new("media/you_win.png", :tileable => true)
    @clam_image = Gosu::Image.new("media/clam.png", :tileable => true)
    @left_tray_image = Scale.new(80, 153, 3)
    @right_tray_image = Scale.new(560, 153, 4)
    @base_image = Gosu::Image.new("media/base.png", :tileable => true)
    @crossbar_image = Crossbar.new(0)
    @rand = %w(brown pink red turquoise yellow green white black dr_green blue orange dr_blue  )
    @rand = @rand[rand(@rand.length)]
    # @rand = "white"
    @pearls = []
    @pearls << Pearl.new(self,2,400,"brown", @rand)
    @pearls << Pearl.new(self,3,400,"pink", @rand)
    @pearls << Pearl.new(self,4,400,"red", @rand)
    @pearls << Pearl.new(self,5,400,"turquoise", @rand)
    @pearls << Pearl.new(self,6,400,"yellow", @rand)
    @pearls << Pearl.new(self,7,400,"green", @rand)
    @pearls << Pearl.new(self,2,300,"dr_green", @rand)
    @pearls << Pearl.new(self,3,300,"blue", @rand)
    @pearls << Pearl.new(self,4,300,"orange", @rand)
    @pearls << Pearl.new(self,7,300,"black", @rand)
    @pearls << Pearl.new(self,6,300,"white", @rand)
    @pearls << Pearl.new(self,5,300,"dr_blue", @rand)

    @spots = []
    (1..9).each{|n|@spots << Spot.new((840/9)*n - (840/9),400,false, "base")}
    (1..9).each{|n|@spots << Spot.new((840/9)*n - (840/9),300,false, "base")}
    @spots << Spot.new(self.width/2 - 350,180,0,"left")
    @spots << Spot.new(self.width/2 - 285,180,0,"left")
    @spots << Spot.new(self.width/2 - 220,180,0,"left")
    @spots << Spot.new(self.width/2 - 320,120,0,"left")
    @spots << Spot.new(self.width/2 - 255,120,0,"left")
    @spots << Spot.new(self.width/2 - 290,60,0,"left")
    @spots << Spot.new(self.width/2 + 350 - 75,180,0,"right")
    @spots << Spot.new(self.width/2 + 285 - 75,180,0,"right")
    @spots << Spot.new(self.width/2 + 220 - 75,180,0,"right")
    @spots << Spot.new(self.width/2 + 320 - 75,130,0,"right")
    @spots << Spot.new(self.width/2 + 255 - 75,130,0,"right")
    @spots << Spot.new(self.width/2 + 290 - 75,80,0,"right")
    @spots << @win_spot = Spot.new(self.width/2-12 ,50,0,"win_check")
    @test_count = 0
  end


  def draw
    # @font.draw_text(@spots.map(&:spot_weight),0,0, 4, 1.0, 1.0, Gosu::Color::BLACK) if $is_demo
    # @font.draw_text(@pearls.map(&:weight),0,15, 4, 1.0, 1.0, Gosu::Color::BLACK) if $is_demo
    if $is_win
      scale_uses_message = "You Win!!"
    else
      scale_uses_message = @test_count <= 3 ? "Scale Uses: " + @test_count.to_s : "You're out of uses of the scale (press esc)"
    end
    directions_1 = "One of these colorful pearls is a different weight than the rest. Simply place the correct pearl inside the"
    directions_2 = "clam.  Balance scale will help but you only get three uses."
    directions_3 = "Press Enter to use scale and check if you"
    directions_4 = "placed the correct pearl inside the clam."
    @font.draw_text(directions_1,0,0, 4, 1.0, 1.0, Gosu::Color::BLACK)
    @font.draw_text(directions_2,0,15, 4, 1.0, 1.0, Gosu::Color::BLACK)
    @font.draw_text(directions_3,0,45, 4, 1.0, 1.0, Gosu::Color::BLACK)
    @font.draw_text(directions_4,0,60, 4, 1.0, 1.0, Gosu::Color::BLACK)
    @font.draw_text(scale_uses_message,0,95, 4, 1.0, 1.0, Gosu::Color::BLACK)

    @background_image.draw(0, 0, 0)
    @clam_image.draw(self.width/2-30 ,30, 0)
    @you_win_image.draw(210, 120, 10) if $is_win
    @left_tray_image.draw()
    @right_tray_image.draw()
    @base_image.draw(840/2-@base_image.width/2, 480/2-@base_image.height/2-49, 4)
    @crossbar_image.draw
    # @brown_pearl.draw(@font)
    # @pink_pearl.draw(@font)
    # @dr_green_pearl.draw(@font)
    # @red_pearl.draw(@font)
    # @turquoise_pearl.draw(@font)
    # @green_pearl.draw(@font)
    # @blue_pearl.draw(@font)
    # @orange_pearl.draw(@font)
    # @yellow_pearl.draw(@font)
    # @dr_blue_pearl.draw(@font)
    # @white_pearl.draw(@font)
    # @black_pearl.draw(@font)
    @pearls.each{|pearl| pearl.draw(@font)}
    @spots.each{|spot| spot.draw(@font)} if $is_demo
  end
  def update
    if @test_count <= 3 || $is_demo = true
      @pearls.each{|pearl| pearl.move(mouse_x,mouse_y,@spots,@pearls - [pearl])}
      @spots.each{|spot| spot.check(@pearls)}
      # @brown_pearl.move(mouse_x,mouse_y,@spots,@pearls - [@brown_pearl])
      # @pink_pearl.move(mouse_x,mouse_y,@spots,@pearls - [@pink_pearl])
      # @dr_green_pearl.move(mouse_x,mouse_y,@spots,@pearls - [@dr_green_pearl])
      # @red_pearl.move(mouse_x,mouse_y,@spots,@pearls - [@red_pearl])
      # @turquoise_pearl.move(mouse_x,mouse_y,@spots,@pearls - [@turquoise_pearl])
      # @green_pearl.move(mouse_x,mouse_y,@spots,@pearls - [@green_pearl])
      # @blue_pearl.move(mouse_x,mouse_y,@spots,@pearls - [@blue_pearl])
      # @orange_pearl.move(mouse_x,mouse_y,@spots,@pearls - [@orange_pearl])
      # @yellow_pearl.move(mouse_x,mouse_y,@spots,@pearls - [@yellow_pearl])
      # @dr_blue_pearl.move(mouse_x,mouse_y,@spots,@pearls - [@dr_blue_pearl])
      # @white_pearl.move(mouse_x,mouse_y,@spots,@pearls - [@white_pearl])
      # @black_pearl.move(mouse_x,mouse_y,@spots,@pearls - [@black_pearl])
      # @trays.each{|tray| tray.move}
      @spots.each{|spot| spot.move(@spots,@right_tray_image,@left_tray_image,@crossbar_image, @test_count)}
    end

    @win_spot.is_win?(@win_spot)
  end
  def button_down(id)
    if id == Gosu::KB_ESCAPE
      close
    else
      super
    end
    if id == Gosu::KbReturn
      @test_count += 1 if !$is_win
    end
  end
  def needs_cursor?
    true
  end
end
Tutorial.new.show if __FILE__ == $0
