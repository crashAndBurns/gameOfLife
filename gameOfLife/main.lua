--[[
   Conway's Game of Life
   By: Jeremy Doolin
   Forked from Brian Honahan's implementation:

   https://github.com/brianhonohan/sketchbook/tree/main/love2d/game-of-life
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
end

function love.update(dt)

   -- STEP 5 -- 
   
   -- if the game is not paused
   --   reduce step time by dt
   --   if step time hits 0 (or less)
   --     reset step time to 0.2
   --     call stepGrid(cellGrid)

end

function love.draw()

   -- STEP 2 --
   -- draw the grid canvas
  love.graphics.draw(gridCanvas)
  
   -- STEP 4 --
   -- draw the cell grid (it has its own method)
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
      love.graphics.line(0, 0, 0, i * _cellWidth)
    end

  -- Draw Grid Columns
   -- loop from 1 to grid.numCols
   --   draw a vertical line from top to bottom of the screen at the correct X coordinate
   --   (Hint: use 'j' and _cellWidth to determine the X coordinate)
    for j = 1, grid.numCols do
      love.graphics.line(0, 0, j * _cellWidth, 0)
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
    -- calculate Y coordinate value (based on row and cellWidth)

    -- If the cell state is alive/true...
    --   set color (bright green is nice, but you can try others)
    
       -- draw a filled rectangle of correct width/height at correct x/y 

    -- After the if statement, reset color to full white

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




-- Handles keyboard input
function love.keypressed(key)

   -- STEP 6: Pause/Unpause with Spacebar -- 
   
   -- If the spacebar is pressed
   --   toggle paused variable

   -- BONUS: randomize the grid
   -- If the 'r' key is pressed and the game is paused
   --   randomize the whole grid
end

-- Handles mouse input
function love.mousepressed(x, y, button, istouch, presses)

   -- STEP 7 --
   
   -- If the game is paused and mouse button is 1
   --   get the cell index based on the X/Y coordinate
   --   toggle the cell
end

      
