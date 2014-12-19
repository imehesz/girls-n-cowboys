window.addEventListener "load", ->
  DEBUG=true
  BACKGROUND_CLOUD="background-cloud.png"
  maxLevel = 7
  currentLevel = 1
  maxLife = 3
  
  #currentLevel = prompt("Level (max: " + maxLevel + ")", currentLevel) if DEBUG is true

  Q = window.Q = Quintus(development:true)
    .include "Sprites, Scenes, Input, 2D, Anim, Touch, UI"
    .setup({maximize:true}).controls().touch()

  Q.Sprite.extend "Player",
    init: (p) ->
      @once = false
      
      @._super p,
        sheet: "player"
        sprite: "player"
        jumpSpeed: -375
        x: 50
        y: 201
        direction: "left"
        score: 0
        lives: maxLife

      @.add "2d, platformerControls, animation" 
      
      @.on "hit.sprite", (collision) ->
        updateCoins = false
        if collision.obj.isA "Tower"
          Q.stageScene "endGame", 1,
            label: "You Won!"
            action: "levelUp"
          @.destroy()
          
        if collision.obj.isA "Number1"
          @.p.score += 10
          collision.obj.destroy()
          updateCoins = true
  
        if collision.obj.isA "Number2"
          @.p.score += 20
          collision.obj.destroy()
          updateCoins = true
          
        if updateCoins
          coinsLabel = Q("UI.Text",1).items[1]
          coinsLabel.p.label = "Points x " + @.p.score
          
        console.log @.p.points
    damage: ->
      console.log "damaging..."
      if (!@.p.timeInvincible)
        @.p.lives--
        @.p.timeInvincible = 1
        
        if (@.p.lives < 0)
          @.destroy()
          Q.stageScene "endGame", 1, label: "Game Over :/ Points: " + @.p.score
        else
          livesLabel = Q("UI.Text",1).items[0]
          livesLabel.p.label = "Lives x " + @.p.lives
    
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
          
      if @.p.timeInvincible > 0
        @.p.timeInvincible = Math.max @.p.timeInvincible-dt, 0

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
          collision.obj.damage()
          
      @.on "bump.top", (collision) ->
        if collision.obj.isA "Player"
          @.destroy()
          collision.obj.p.vy = -300
          collision.obj.p.score += 50
          scoreLabel = Q("UI.Text",1).items[1]
          scoreLabel.p.label = "Points x " + collision.obj.p.score
  
  Q.Sprite.extend "Number0",
    init: (p) ->
      @._super p, sheet: "number0"
        
      @.add "2d, aiBounce"
      
      @.on "bump.top", (collision) ->
        if collision.obj.isA "Player"
          console.log "got bumpedd, pickup the number!"
          collision.obj.c.x = collision.obj.p.x
          collision.obj.c.y = collision.obj.p.y
          
  Q.Sprite.extend "Number1",
    init: (p) ->
      @._super p, sheet: "number1"
      @.add "2d, aiBounce"
      
  Q.Sprite.extend "Number2",
    init: (p) ->
      @._super p, sheet: "number2"
      @.add "2d"
  
  Q.scene "gameStats", (stage) ->
    container = stage.insert new Q.UI.Container
      id: "welcomemessage"
      fill: "gray",
      border: 5,
      shadow: 10,
      shadowColor: "rgba(0,0,0,0.5)",
      y: 30,
      x: document.body.clientWidth/2,
      w: 960,
      h: 40
      
    #alert $(window).width()
      
    lives = stage.insert new Q.UI.Text(
      label: "Lives x 3",
      color: "gold",
      x: -300,
      y: 0), container
      
    points = stage.insert new Q.UI.Text(
      label: "Points x 0",
      color: "gold",
      x: 300,
      y: 0), container
    
  Q.scene "level1", (stage) ->
    Q.stageScene "gameStats",1
    stage.insert new Q.Repeater(
      asset: BACKGROUND_CLOUD
      speedX: 0.5
      speedY: 0.5)
    
    stage.collisionLayer new Q.TileLayer dataAsset: "level1.json", sheet: "tiles"
    
    player = stage.insert new Q.Player()
    
    stage.add("viewport").follow player
    
    #stage.insert new Q.Number0 x: 600, y: 225
    stage.insert new Q.Number1 x: 600, y: 225
    stage.insert new Q.Number2 x: 640, y: 225
    
    stage.insert new Q.Tower x:1000, y:210

    stage.insert new Q.Enemy x: 800, y:210

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
    
  Q.scene "level2", (stage) ->
    stage.insert new Q.Repeater
      asset: BACKGROUND_CLOUD
      speedX: 0.5
      speedY: 0.5

    stage.collisionLayer new Q.TileLayer dataAsset: "level2.json", sheet: "tiles"
    
    player = stage.insert new Q.Player()
    
    stage.add("viewport").follow player
    stage.insert new Q.Tower
      x:1000
      y:210

  Q.scene "level3", (stage) ->
    stage.insert new Q.Repeater
      asset: BACKGROUND_CLOUD
      speedX: 0.5
      speedY: 0.5

    stage.collisionLayer new Q.TileLayer dataAsset: "level3.json", sheet: "tiles"
    
    player = stage.insert new Q.Player()
    
    stage.add("viewport").follow player
    stage.insert new Q.Tower
      x:1000
      y:210

  Q.scene "endGame", (stage) ->
    container = stage.insert new Q.UI.Container x: Q.width/2, y: Q.height/2, fill: "rgba(0,0,0,0.5)"
    button = container.insert new Q.UI.Button x: 0, y: 0, fill: "#CCCCCC", label: "Play"
    label = container.insert new Q.UI.Text x: 10, y: -10-button.p.h, label: stage.options.label
    
    currentLevel++ if stage.options.action = "levelUp" and currentLevel < maxLevel
    
    button.on "click", ->
      Q.clearStages()
      Q.stageScene("level1");
      
    container.fit(20)
      
  Q.load "numbers.png, numbers.json, girls-n-cowboys-sprites.png, sprites.json, level1.json, level2.json, level3.json, girls-n-cowboys-tiles.png, background-wall.png, " + BACKGROUND_CLOUD, ->
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