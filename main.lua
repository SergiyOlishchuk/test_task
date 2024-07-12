function create_maze(filename)
    local maze = {}
    local start = {}
    local finish = {}
    local file = io.open(filename)

    if file then
        local row = 1
        for line in file:lines() do
            maze[row] = {}
            for col = 1, #line do
                maze[row][col] = line:sub(col, col)
                if maze[row][col] == 'I' then
                    start[1] = row
                    start[2] = col
                    maze[row][col] = ' '
                end
                if maze[row][col] == 'E' then
                    finish[1] = row
                    finish[2] = col
                    maze[row][col] = ' '
                end
            end
            row = row + 1
        end
        file:close()
    end
    return maze, start, finish
end

function write_maze(maze, filename)
    local file = io.open(filename, 'w')
    if not file then
        print('Can not write maze')
        return
    end

    for i = 1, #maze do
        for j = 1, #maze[i] do
            file:write(maze[i][j])
        end
        file:write('\n')
    end
    file:close()
end

function findShortestPath(maze, start, finish)
    local rows = #maze
    local cols = #maze[1]

    if maze[start[1]][start[2]] == 0 or maze[finish[1]][finish[2]] == 0 then
        print('Start or finish is in wall')
        return nil
    end

    local queue = {}
    table.insert(queue, start)

    local visited = {}
    for i = 1, rows do
        visited[i] = {}
        for j = 1, cols do
            visited[i][j] = false
        end
    end
    visited[start[1]][start[2]] = true

    local parent = {}
    for i = 1, rows do
        parent[i] = {}
        for j = 1, cols do
            parent[i][j] = nil
        end
    end

    local directions = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}}

    while #queue > 0 do
        local current = table.remove(queue, 1)

        if current[1] == finish[1] and current[2] == finish[2] then
            break
        end

        for _, dir in ipairs(directions) do
            local next_row = current[1] + dir[1]
            local next_col = current[2] + dir[2]

            if next_row >= 1 and next_row <= rows and next_col >= 1 and next_col <= cols
                    and maze[next_row][next_col] ~= '0' and not visited[next_row][next_col] then
                table.insert(queue, {next_row, next_col})
                visited[next_row][next_col] = true
                parent[next_row][next_col] = current
            end
        end
    end
    if not visited[finish[1]][finish[2]] then
        return nil
    end
    local path = {}
    local current = finish
    while current do
        table.insert(path, 1, current)
        current = parent[current[1]][current[2]]
    end
    return path
end

function main()
    local maze, start, finish = create_maze('Maze.txt')
    if #maze <= 0 or #start ~= 2 or #finish ~= 2 then
        print('Something wrong')
        return
    end

    local path = findShortestPath(maze, start, finish)
    if not path then
        print('Can not find the path')
        return
    end
    for i = 1, #path do
        maze[path[i][1]][path[i][2]] = '*'
    end
    maze[start[1]][start[2]] = 'I'
    maze[finish[1]][finish[2]] = 'E'
    write_maze(maze, 'path.txt')
end

main()