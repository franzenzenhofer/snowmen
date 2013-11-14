Snowmen = new Meteor.Collection("snowmen")
Flowers = new Meteor.Collection("flowers")
#Snowmen.remove({})

snowmanwidth = 14
snowmanheight = 18

snowman_pixel_speed = 7

fullRand = (min = 0, max = 600) -> Math.floor(Math.random()*(max+1))

collision = (a_x, a_y, b_x, b_y) ->
  #console.log(arguments)
  r = a_x < b_x + snowmanwidth &&
  a_x + snowmanwidth > b_x &&
  a_y < b_y + snowmanheight &&
  a_y + snowmanheight > b_y
  #console.log(r)
  r

getRandomColor = ->
  letters = "0123456789ABCDEF".split("")
  color = "#"
  i = 0
  while i < 6
    color += letters[Math.round(Math.random() * 15)]
    i++
  color

addFlower = (x = 0,y = 0, color) ->
 Flowers.insert
  'x': x
  'y': y
  'color': color ? getRandomColor()
  'created': new Date()

getAllFlowers = () ->
  Flowers.find({})

addSnowman = (x = 0,y = 0) ->
 Snowmen.insert
  'x': x
  'y': y
  'color': getRandomColor()
  'created': new Date()
  'last_mod': new Date()

getSnowmanById = (id) ->
  Snowmen.findOne({'_id':id})

getAllSnowmen = () ->
  Snowmen.find({})

updateSnowman = (id, x, y, color) ->
  Snowmen.update({'_id':id}, {'$set':
      'x':x
      'y':y
      'color': color
      'last_mod': new Date()
    }
    )

upgradeSnowman = (id, x, y, color) -> 
  my = getMySnowman()
  x = x ? my.x
  y = y ? my.y
  color = color ? my.color
  updateSnowman(id, x, y, color)

removeSnowman = (id) ->
  Snowmen.remove(id)

if Meteor.isServer
  cleanUp = () ->
    d = new Date()
    milsec = d.getTime()
    milsec_minus20 = milsec-(20*1000)
    snowmen = getAllSnowmen()
    snowmen.forEach((snowman)->
      if Date.parse(snowman.last_mod) < milsec_minus20
        removeSnowman(snowman._id)
        console.log('removed')
      )
  Meteor.setInterval(cleanUp, 5000)


if Meteor.isClient
  updateMySnowman = (x, y, c) ->
    upgradeSnowman(Session.get('id'), x, y, c)

  spawnMySnowman = () ->
    #console.log()
    Session.set('id', addSnowman(fullRand(0,window.document.width), fullRand(0,window.document.height)))

  getMySnowman = () ->
    my = getSnowmanById(Session.get('id'))
    if not my
      spawnMySnowman()
      return getMySnowman()
    else 
      return my

  didICollide = (new_x, new_y) ->
    my = getMySnowman()
    x = new_x ? my.x
    y = new_y ? my.y
    snowmen = getAllSnowmen()
    r = false
    snowmen.forEach((snowman) ->
      if snowman._id isnt Session.get('id')
        if collision(x,y, snowman.x, snowman.y)
          r = true
          return true
      )
    return r




  moveMySnowman = (e, urdl = {}) ->
    e.preventDefault()
    my = getMySnowman()
    x = my.x
    y = my.y
    if urdl.up then y = y-snowman_pixel_speed
    if urdl.right then x = x+snowman_pixel_speed
    if urdl.down then y = y+snowman_pixel_speed
    if urdl.left then x = x-snowman_pixel_speed
    if x > 0 and y > 0 and (x isnt my.x or y isnt my.y)
      if not didICollide(x, y)
        updateMySnowman(x, y)

  plantFlower = (e) ->
    e.preventDefault()
    my = getMySnowman()
    addFlower(my.x, my.y, my.color)

  keypress.combo('up', (e) ->
    moveMySnowman(e,
      'up': true
      )
    )

  keypress.combo('down', (e) ->
    moveMySnowman(e,
      'down': true
      )
    )

  keypress.combo('right', (e) ->
    moveMySnowman(e,
      'right': true
      )
    )

  keypress.combo('left', (e) ->
    moveMySnowman(e,
      'left': true
      )
    )

  keypress.combo('left up', (e) ->
    moveMySnowman(e,
      'left': true
      'up': true
      )
    )

  keypress.combo('left down', (e) ->
    moveMySnowman(e,
      'left': true
      'down': true
      )
    )

  keypress.combo('right up', (e) ->
    moveMySnowman(e,
      'right': true
      'up': true
      )
    )

  keypress.combo('right down', (e) ->
    moveMySnowman(e,
      'right': true
      'down': true
      )
    )

  keypress.combo('space', (e) ->
    plantFlower(e)
    )

  spawnMySnowman()

  Template.main.snowmen = ->
    getAllSnowmen()

  Template.grass.flowers = ->
    getAllFlowers()


#    f = ''
#    for y in [0 ... height]
#      do (y) ->
#        for x in [0 ... width]
#          do (x) ->
#            if a?[y]?[x]
#              f = f + 'X'
#            else
#              f = f + '.'
#        f = f + "\n"
#    return f