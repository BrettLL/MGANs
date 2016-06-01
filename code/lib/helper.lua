function computeBB(width, height, alpha)
  local min_x, min_y, max_x, max_y
  local x1 = 1
  local y1 = 1
  local x2 = width
  local y2 = 1
  local x3 = width
  local y3 = height
  local x4 = 1
  local y4 = height
  local x0 = width / 2
  local y0 = height / 2

  x1r = x0+(x1-x0)*math.cos(alpha)+(y1-y0)*math.sin(alpha)
  y1r = y0-(x1-x0)*math.sin(alpha)+(y1-y0)*math.cos(alpha)

  x2r = x0+(x2-x0)*math.cos(alpha)+(y2-y0)*math.sin(alpha)
  y2r = y0-(x2-x0)*math.sin(alpha)+(y2-y0)*math.cos(alpha)

  x3r = x0+(x3-x0)*math.cos(alpha)+(y3-y0)*math.sin(alpha)
  y3r = y0-(x3-x0)*math.sin(alpha)+(y3-y0)*math.cos(alpha)

  x4r = x0+(x4-x0)*math.cos(alpha)+(y4-y0)*math.sin(alpha)
  y4r = y0-(x4-x0)*math.sin(alpha)+(y4-y0)*math.cos(alpha)

  -- print(x1r .. ' ' .. y1r .. ' ' .. x2r .. ' ' .. y2r .. ' ' .. x3r .. ' ' .. y3r .. ' ' .. x4r .. ' ' .. y4r)
  if alpha > 0 then
    -- find intersection P of line [x1, y1]-[x4, y4] and [x1r, y1r]-[x2r, y2r]
    local px1 = ((x1 * y4 - y1 * x4) * (x1r - x2r) - (x1 - x4) * (x1r * y2r - y1r * x2r)) / ((x1 - x4) * (y1r - y2r) - (y1 - y4) * (x1r - x2r))
    local py1 = ((x1 * y4 - y1 * x4) * (y1r - y2r) - (y1 - y4) * (x1r * y2r - y1r * x2r)) / ((x1 - x4) * (y1r - y2r) - (y1 - y4) * (x1r - x2r))
    local px2 = px1 + 1
    local py2 = py1
    -- print(px1 .. ' ' .. py1)
    -- find the intersection Q of line [px1, py1]-[px2, for color image in matlab py2] and [x2r, y2r]-[x3r][y3r]

    local qx = ((px1 * py2 - py1 * px2) * (x2r - x3r) - (px1 - px2) * (x2r * y3r - y2r * x3r)) / ((px1 - px2) * (y2r - y3r) - (py1 - py2) * (x2r - x3r))
    local qy = ((px1 * py2 - py1 * px2) * (y2r - y3r) - (py1 - py2) * (x2r * y3r - y2r * x3r)) / ((px1 - px2) * (y2r - y3r) - (py1 - py2) * (x2r - x3r))  
    -- print(qx .. ' ' .. qy)

    min_x = width - qx
    min_y = qy
    max_x = qx
    max_y = height - qy
  else if alpha < 0 then
    -- find intersection P of line [x2, y2]-[x3, y3] and [x1r, y1r]-[x2r, y2r]
    local px1 = ((x2 * y3 - y2 * x3) * (x1r - x2r) - (x2 - x3) * (x1r * y2r - y1r * x2r)) / ((x2 - x3) * (y1r - y2r) - (y2 - y3) * (x1r - x2r))
    local py1 = ((x2 * y3 - y1 * x3) * (y1r - y2r) - (y2 - y3) * (x1r * y2r - y1r * x2r)) / ((x2 - x3) * (y1r - y2r) - (y2 - y3) * (x1r - x2r))
    local px2 = px1 - 1
    local py2 = py1
    -- find the intersection Q of line [px1, py1]-[px2, py2] and [x1r, y1r]-[x4r][y4r]
    local qx = ((px1 * py2 - py1 * px2) * (x1r - x4r) - (px1 - px2) * (x1r * y4r - y1r * x4r)) / ((px1 - px2) * (y1r - y4r) - (py1 - py2) * (x1r - x4r))
    local qy = ((px1 * py2 - py1 * px2) * (y1r - y4r) - (py1 - py2) * (x1r * y4r - y1r * x4r)) / ((px1 - px2) * (y1r - y4r) - (py1 - py2) * (x1r - x4r))  
    min_x = qx
    min_y = qy
    max_x = width - min_x
    max_y = height - min_y
    else
      min_x = x1
      min_y = y1
      max_x = x2
      max_y = y3
    end
  end

  return math.floor(min_x), math.floor(min_y), math.floor(max_x), math.floor(max_y)
end

function computegrid(width, height, block_size, block_stride, flag_all)
  coord_block_y = torch.range(1, height - block_size + 1, block_stride) 
  if flag_all == 1 then
    if coord_block_y[#coord_block_y] < height - block_size + 1 then
      local tail = torch.Tensor(1)
      tail[1] = height - block_size + 1
      coord_block_y = torch.cat(coord_block_y, tail)
    end
  end
  coord_block_x = torch.range(1, width - block_size + 1, block_stride) 
  if flag_all == 1 then
    if coord_block_x[#coord_block_x] < width - block_size + 1 then
      local tail = torch.Tensor(1)
      tail[1] = width - block_size + 1
      coord_block_x = torch.cat(coord_block_x, tail)
    end
  end
  return coord_block_x, coord_block_y
end


function weights_init(m)
   local name = torch.type(m)
   if name:find('Convolution') then
      m.weight:normal(0.0, 0.02)
      m.bias:fill(0)
   elseif name:find('BatchNormalization') then
      if m.weight then m.weight:normal(1.0, 0.02) end
      if m.bias then m.bias:fill(0) end
   end
end

