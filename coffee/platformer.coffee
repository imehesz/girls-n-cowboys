window.addEventListener "load", ->
  DEBUG=true
  BACKGROUND_CLOUD="background-cloud.png"
  maxLevel = 7
  currentLevel = 1

  currentLevel = 1 #prompt("Level (max: " + maxLevel + ")", currentLevel) if DEBUG is true

  Q = window.Q = Quintus(development:true)
    .include "Sprites, Scenes, Input, 2D, Anim, Touch, UI"
    .setup({maximize:true}).controls().touch()

  Q.Sprite.extend "Player",
    init: (p) ->
      @once = false
      
      @._super p,
        sheet: "player"
        sprite: "player"
        x: 50
        y: 201
        direction: "left"

      @.add "2d, platformerControls, animation" 
      
      @.on "hit.sprite", (collision) ->
        if collision.obj.isA "Tower"
          Q.stageScene "endGame", 1,
            label: "You Won!"
            action: "levelUp"
          @.destroy()
    step: (dt) ->
      processed = false
      
      if @once is false
        console.log "dt", dt
        console.log "this", @
        @once = true
      
      if not processed
        if @.p.vx > 0
          @.play "walk_right"
        else
          @.play "walk_left"

  Q.Sprite.extend "Tower",
    init: (p) ->
      @._super p, sheet: "tower"
  
  Q.Sprite.extend "Enemy",
    init: (p) ->
      @._super p,
        sheet: "enemy"
        vx: 100
        
      @.add "2d, aiBounce"
      
      @.on "bump.left, bump.right, bump.bottom", (collision) ->
        if collision.obj.isA "Player"
          Q.stageScene "endGame", 1, label: "You Lost :/"
          collision.obj.destroy()
          
      @.on "bump.top", (collision) ->
        if collision.obj.isA "Player"
          @.destroy()
          collision.obj.p.vy = -300
  
  Q.Sprite.extend "Number0",
    init: (p) ->
      @._super p, sheet: "number0"
        
      @.add "2d, aiBounce"
      
      @.on "bump.top", (collision) ->
        if collision.obj.isA "Player"
          console.log "got bumpedd, pickup the number!"
          collision.obj.c.x = collision.obj.p.x
          collision.obj.c.y = collision.obj.p.y
  
  Q.scene "level1", (stage) ->
    stage.insert new Q.Repeater(
      asset: BACKGROUND_CLOUD
      speedX: 0.5
      speedY: 0.5)
    
    stage.collisionLayer new Q.TileLayer dataAsset: "level1.json", sheet: "tiles"
    
    player = stage.insert new Q.Player()
    
    stage.add("viewport").follow player
    
    #stage.insert new Q.Number0 x: 600, y: 225
    
    stage.insert new Q.Tower
      x:1000
      y:210
      
    container = stage.insert new Q.UI.Container
      id: "welcomemessage"
      fill: "gray",
      border: 5,
      shadow: 10,
      shadowColor: "rgba(0,0,0,0.5)",
      y: 135,
      x: 250 
    
    stage.insert new Q.UI.Text( 
      label: "Hi, my name is Princess V.\nCan you help me find my castle?",
      color: "white",
      x: 0,
      y: 0), container
    
    container.fit 5,5

  Q.scene "endGame", (stage) ->
    container = stage.insert new Q.UI.Container x: Q.width/2, y: Q.height/2, fill: "rgba(0,0,0,0.5)"
    button = container.insert new Q.UI.Button x: 0, y: 0, fill: "#CCCCCC", label: "Play"
    label = container.insert new Q.UI.Text x: 10, y: -10-button.p.h, label: stage.options.label
    
    currentLevel++ if stage.options.action = "levelUp" and currentLevel < maxLevel
    
    button.on "click", ->
      Q.clearStages()
      Q.stageScene("level" + currentLevel);
      
    container.fit(20)
      
  Q.load "numbers.png, numbers.json, girls-n-cowboys-sprites.png, sprites.json, level1.json, level2.json, level5.json, girls-n-cowboys-tiles.png, background-wall.png, " + BACKGROUND_CLOUD, ->
    Q.sheet "tiles", "girls-n-cowboys-tiles.png", tilew: 32, tileh: 32
    Q.compileSheets "girls-n-cowboys-sprites.png", "sprites.json"
    Q.compileSheets "numbers.png", "numbers.json"
    
    Q.animations "player", 
      walk_right:
        flip: "x"
        loop: true
        rate: 1/3
        frames: [0]
      walk_left:
        flip: false
        loop: true
        rate: 1/3
        frames: [0]
    
    Q.stageScene "level" + currentLevel
   
  return