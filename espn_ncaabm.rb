# require 'rubygems'
 
# require 'nokogiri'
# require 'open-uri'
# require 'active_record'
# require 'active_support'
# game_id = 330550194
# page = Nokogiri::HTML(open("http://espn.go.com/ncb/boxscore?id=#{game_id}"))
# headers = page.css("div#my-players-table .colhead th")
# player_rows = page.css("div#my-players-table td")
# box_score = []
# #headers.collect {|head| head.text}.map! { |x| x == "STARTERS" ? "PLAYER" : x }.slice!(0..12) 
# #player_rows.collect {|player| player.text}   
# #box_score = headers.collect {|head| head.text.downcase}.map! { |w| w == "starters" ? "player" : w}.map! { |x| x == "fgm-a" ? "fg" : x}.map! {|y| y == "3pm-a" ? "threep" : y}.map! {|z| z == "ftm-a" ? "ft" : z }.slice!(0..12).zip(player_rows.collect {|player| player.text} )
# headers = headers.collect {|head| head.text}.map!
#           { |w| w == "starters" ? "player" : w}.map!
#           { |x| x == "fgm-a" ? "fg" : x}.map!
#           { |y| y == "3pm-a" ? "threep" : y}.map!
#           { |z| z == "ftm-a" ? "ft" : z }
# player_rows = player_rows.collect {|player| player.text}
# def combine(header,rows)
#   #join each row to its header
#   joint = []
#   for j in 1..15 do
#     for i in 0..12 do 
#       joint << header[i]+":"+rows[i*j]
  
#     end
#   puts joint
#   end
# end

# class NcaaGameStats
#     attr_accessor :player, :min, :fg, :threep, :ft, :oreb, :reb, :ast, :stl, :blk, :to, :pf, :pts
#   def initialize (player="", min="", fg="", threep="", ft="", oreb="", reb="", ast="", stl="", blk="", to="", pf="", pts="")
#     @player = player
#     @min = min
#     @fg = fg
#     @threep = threep
#     @ft = ft
#     @oreb = oreb
#     @reb = reb
#     @ast = ast
#     @stl = stl
#     @blk = blk
#     @to = to
#     @pf = pf
#     @pts = pts
#   end
 
# end

#-------------------Create DB
db = SQLite3::Database.new("ncaamb.db")
rows = db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS gameid_#{number} (
    id INTEGER PRIMARY KEY autoincrement,
    title text,
    start text,
    home_team text,
    away_team text,
    player text,
    min INTEGER,
    fg text,
    threep text,
    ft text,
    oreb INTEGER,
    reb INTEGER,
    ast INTEGER,
    stl INTEGER,
    blk INTEGER,
    to INTEGER,
    pf INTEGER,
    pts INTEGER
  );
SQL
#-------------- Game Class
require 'nokogiri'
require 'open-uri'
class Game
  attr_accessor :game_id, :title, :start, :home_team, :away_team, :headers, :players_rows, :players_stats, :statsdoc 

  def initialize(game_id, date = "", home_team = "", away_team = "", players_stats = {})
    @game_id = game_id
    @statsdoc = Nokogiri::HTML(open("http://scores.espn.go.com/ncb/boxscore?gameId=330550194"))
    @title = title
    @start = start
    @home_team = home_team
    @away_team = away_team
    @headers = headers
    @players_rows = players_rows
    @players_stats = players_stats #Nested hash with player name=>stat_title =>stat
  end
# create a DB for each game per ESPN convention
  #@@db = SQLite3::Database.new("#{game_id}.db")
  def scrape_all
    scrape_title
    scrape_home_team
    scrape_away_team
    scrape_start
    
  end
  
  def scrape_title
    self.title = statsdoc.css("title").text
  end

  def scrape_home_team
    self.home_team = statsdoc.css("div.team-info a").first.text
  end

  def scrape_away_team
    self.away_team = statsdoc.css("div.team-info a").last.text
  end
  
  def scrape_start
    self.start = statsdoc.css("div.game-time-location p").first.text
  end
  
  def scrape_stat_headers
    headers = statsdoc.css("div#my-players-table .colhead th")
    headers = headers.collect {|head| head.text.downcase}
      .map!{ |w| w == "starters" ? "player" : w}
      .map!{ |x| x == "fgm-a" ? "fg" : x}
      .map!{ |y| y == "3pm-a" ? "threep" : y}
      .map!{ |z| z == "ftm-a" ? "ft" : z }

    headers.slice!(headers.index("bench")..headers.length)
    self.headers = headers
  end

  def scrape_players_rows
    players_rows = statsdoc.css("div#my-players-table td")
    players_rows = players_rows.collect {|player| player.text}
    self.players_rows = players_rows
  end

  def add_headers_players
    self.players_stats = []
    i = 0
    j= i*13
    while i < 8 do
    self.players_stats << headers.zip(players_rows[j..(12+j)])
    i += 1
    j = i*13
    end
  end
end
test = Game.new(330550194)
test.scrape_stat_headers
test.scrape_players_rows
test.add_headers_players
test.players_stats
#   def save
#     @@db.execute(
#         "INSERT INTO ? (title, start, home_team, away_team, player, min, fg, threep, ft, oreb, reb, ast, stl, blk, to, pf, pts)
#         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", 
#         [game_id, title, start, home_team, away_team, player, min, fg, threep, ft, oreb, reb, ast, stl, blk, to, pf, pts]);
#   end

# end

