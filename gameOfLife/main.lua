--[[
   Conway's Game of Life
   By: Jeremy Doolin
   Forked from Brian Honahan's implementation:

   https://github.com/brianhonohan/sketchbook/tree/main/love2d/game-of-life

   With edits by Frank E. Ciszek for Video Game Development Fundamentals
   at WVNCC.
]]--


function love.load()

   -- Set some global variables
   gameWidth = love.graphics.getWidth()
   gameHeight = love.graphics.getHeight()
   cellGrid = {} -- the cells are stored as an array of booleans
   cellWidth = 8 -- the pixel width of the cells. May be adjusted as desired.

   -- The grid will be drawn once, to a canvas.
   -- Then the canvas will be drawn each frame
   gridCanvas = love.graphics.newCanvas(gameWidth, gameHeight)

   paused = true -- the paused state variable, can be toggled with spacebar
   stepTime = 0.2 -- the amount of time between game steps
   initGrid(cellGrid, cellWidth) -- initialize the cell grid
   drawGridCanvas(cellGrid, cellWidth) -- draw the grid to the canvas

   -- FEC 2/5/2026 added a generation tracking variable for use in tracking
   -- the number of permutations of the pattern.
   generationNum = 0
   font = love.graphics.newFont("/press-start-2p-font/PressStart2P-vaV7.ttf")
end

function love.update(dt)

   -- STEP 5 -- 
   
   -- if the game is not paused
  if not paused then
   --   reduce step time by dt
    stepTime = stepTime - dt
   --   if step time hits 0 (or less)
    if stepTime <= 0 then
   --     reset step time to 0.2
      stepTime = 0.2
   --     call stepGrid(cellGrid)
      stepGrid(cellGrid)

    generationNum = generationNum + 1
    end
  end
end

function love.draw()
   -- STEP 2 --
   -- draw the grid canvas
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(gridCanvas)
  love.graphics.setColor(0, 0, 0)
  
   -- STEP 4 --
   -- draw the cell grid (it has its own method)
  love.graphics.setColor(1, 1, 1, 1)
  drawGrid(cellGrid)
  love.graphics.setColor(0, 0, 0)

  -- FEC 2/5/2026 Generation tracker added to the upper lefthand corner of the game
  love.graphics.setColor(1, 0, 0)

  -- FEC 2/5/2026 Added a new font for the generation tracker
  love.graphics.setFont(font)
  love.graphics.print("Generation: " ..generationNum, 10, 10, 0, 2, 2)
  love.graphics.setColor(0, 0, 0)

end

function love.quit()
  print("Closing")
end

-- This draws the grid lines to a canvas
function drawGridCanvas(grid, _cellWidth)

   -- STEP 1 --
   -- set canvas to the gridCanvas
  love.graphics.setCanvas(gridCanvas)
   -- set the color to a medium grey
   love.graphics.setColor(.5, .5, .5)

   -- Draw Grid Rows
   -- loop from 1 to grid.numRows
   --   draw a horizontal line across the screen at the correct Y coordinate
   --   (Hint: use 'i' and _cellWidth to determine the Y coordinate)
    for i = 1, grid.numRows do
      -- FEC 2/4/2026
      -- Note: to draw a horizontal line, start at x1 = 0, y1 = 0
      -- x1 for each line doesn't have to move. y2 must move by the cell width,
      -- x2 should be the width of the window and y2 should move by cell width.
      love.graphics.line(0, i * _cellWidth, gameWidth, i * _cellWidth)
    end

  -- Draw Grid Columns
   -- loop from 1 to grid.numCols
   --   draw a vertical line from top to bottom of the screen at the correct X coordinate
   --   (Hint: use 'j' and _cellWidth to determine the X coordinate)
    for j = 1, grid.numCols do
      love.graphics.line(j * _cellWidth, 0, j * _cellWidth, gameHeight)
    end

   -- set the color back to white
    love.graphics.setColor(0, 0, 0)
   -- reset to default canvas
  love.graphics.setCanvas()
end

-- Toggle cell from alive to dead or vice versa
function toggleCell(grid, idx)
   grid.data[idx] = not grid.data[idx]
end 

-- This creates the primary data table of cells
function initGrid(grid, _cellWidth)
  grid.data = {} -- the array of booleans
  grid.wrap = true -- whether or not the game field "wraps"
  grid.numRows = math.floor( gameHeight / _cellWidth ) -- calculates number of rows
  grid.numCols = math.floor( gameWidth / _cellWidth ) -- calculates number of columns
  grid.numCells = grid.numRows * grid.numCols -- calculats total number of cells

end

-- The main drawing function that draws the cell grid
function drawGrid(grid)
  local x = 0 -- X position to draw a cell
  local y = 0 -- Y position to draw a cell
  local row = 0 -- Current row number
  local col = 0 -- Current column number
  local cell -- current cell state (boolean value)

  -- Loop through all the grid cells
  for i = 1,grid.numCells do
    row = rowForIdx(grid, i) -- get the correct row number
    col = colForIdx(grid, i) -- get the correct column number
    cell = grid.data[i] -- get the cell state (true/false)

    -- STEP 3 --

    -- Drawing the squares that are alive 
    
    -- calculate X coordinate value (based on col and cellWidth)
    xCoord = col * cellWidth
    -- calculate Y coordinate value (based on row and cellWidth)
    yCoord = row * cellWidth

    -- If the cell state is alive/true...
    --   set color (bright green is nice, but you can try others)
    love.graphics.setColor(.2, .8, .2)
    if cell then
       -- draw a filled rectangle of correct width/height at correct x/y
      love.graphics.rectangle("fill", xCoord, yCoord, cellWidth, cellWidth)
    end
    -- After the if statement, reset color to full white
    love.graphics.setColor(0, 0, 0)

  end -- for loop through grid cells
end

-- Calculates the grid row based on index number
function rowForIdx(grid, idx)
  return math.floor( (idx-1) / grid.numCols )
end

-- Calculates the grid column based on index number
function colForIdx(grid, idx)
  return (idx-1) % grid.numCols
end

-- Calculates a cell index number from the row and column
-- Used by the next method
function idxFromPos(grid, row, col)
   idx = (row - 1) * grid.numCols + col
   return(idx)
end

-- Calculates a cell index number from an X/Y coordinate
-- This is needed to toggle cell states with the mouse
function idxFromCoord(grid, x, y)
   row = math.ceil(y / cellWidth)
   col = math.ceil(x / cellWidth)
   idx = idxFromPos(grid, row, col)
   return(idx)
end

-- Applies the Game of Life Rules to the whole grid
function stepGrid(grid)
  local newData = {}
  local tmpCount = 0

  for i = 1,grid.numCells do
    tmpCount = countSurrounding(grid, i)
    newData[i] = nextState(grid.data[i], tmpCount)
  end

  grid.data = newData
end

-- Obtains all neighboring cells of current cell
function neighborsForIdx(grid, idx)
  -- optimistically set them (ignoring edge cases)
  local neighbors = {}
  neighbors[1] = idx - grid.numCols - 1
  neighbors[2] = idx - grid.numCols
  neighbors[3] = idx - grid.numCols + 1
  neighbors[4] = idx - 1
  neighbors[5] = idx + 1
  neighbors[6] = idx + grid.numCols - 1
  neighbors[7] = idx + grid.numCols
  neighbors[8] = idx + grid.numCols + 1

  -- check for edge cases

  -- first row
  if (idx < grid.numCols) then
    neighbors[1] = neighbors[1] + grid.numCells
    neighbors[2] = neighbors[2] + grid.numCells
    neighbors[3] = neighbors[3] + grid.numCells
  end

  -- if in left most column
  if (idx % grid.numCols == 0) then
    neighbors[1] = neighbors[1] + grid.numCols
    neighbors[4] = neighbors[4] + grid.numCols
    neighbors[6] = neighbors[6] + grid.numCols
  end

  -- if in right most column
  if (idx % grid.numCols == (grid.numCols - 1)) then
    neighbors[3] = neighbors[3] - grid.numCols
    neighbors[5] = neighbors[5] - grid.numCols
    neighbors[8] = neighbors[8] - grid.numCols
  end

  -- if in bottom row
  if ((grid.numCells - idx) <= grid.numCols) then
    neighbors[6] = neighbors[6] - grid.numCells
    neighbors[7] = neighbors[7] - grid.numCells
    neighbors[8] = neighbors[8] - grid.numCells
  end

  return neighbors
end

-- Counts how many alive cells there are among the neighbors
function countSurrounding(grid, idx)
  local count = 0
  local neighbors = neighborsForIdx(grid, idx)
  local tmpNeighborIdx = 0

  for i=1,8 do
    tmpNeighborIdx = neighbors[i]
    if (grid.data[tmpNeighborIdx]) then
      count = count + 1
    end
  end

  return count
end

-- Uses the Game of Life Rules to get the next State
-- for a given currentState
function nextState(currentState, count)
  if (currentState == true) then
    if (count < 2) then
      return false
    elseif (count > 3) then
      return false
    else
      return true
    end
  else
    return (count == 3)
  end
end

-- BONUS function
-- Should take the grid table as a parameter
-- Returns nothing, as it modifies the grid in place
-- This should loop through the grid and
-- set to random true/false values.
-- FEC 2/5/2026: input parameter is cellGrid
-- first we need a double loop, to loop through the rows and columns
-- then we need to find the cell reference, the upper left hand corner
-- then create a random number from 1 to 100, if the number is even toggle the
-- cell on if the number is odd toggle the cell off.

function randomize(grid)
  for k = 1, grid.numRows do
    for l = 1, grid.numCols do
      local randNum = math.random(100)
      if randNum % 2 == 0 then
        -- toggle cell on
        toggleCell(grid, idxFromPos(grid, k, l))
      end
    end
  end
end

-- Handles keyboard input
function love.keypressed(key)

   -- STEP 6: Pause/Unpause with Spacebar -- 
   
   -- If the spacebar is pressed
   --   toggle paused variable
       -- BONUS: randomize the grid
   -- If the 'r' key is pressed and the game is paused
   --   randomize the whole grid
  if key == "space" then
    paused = not paused
  end

  if paused and (key == "r" or key == "R") then
    randomize(cellGrid)
  end
end

-- Handles mouse input
function love.mousepressed(x, y, button, istouch, presses)
   -- STEP 7 --
   
   -- If the game is paused and mouse button is 1
   --   get the cell index based on the X/Y coordinate
   --   toggle the cell
  
  if paused and button == 1 then
    local toggleCellIdx = idxFromCoord(cellGrid, x, y)
    toggleCell(cellGrid, toggleCellIdx)
  end
end    
