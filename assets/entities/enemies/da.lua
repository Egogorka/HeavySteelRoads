local output = {}

local tank_body_animations = {
    idle = {frames = {1, 1}},
    move = {frames = {1, "1-4"}, durations = 0.2}
}

local tank_tower_animations = {
    right = {frames = {1, 1}},
    right_up = {frames = {1, 2}},
    up = {frames = {1, 3}},
    left_up = {frames = {1, 4}},
    left = {frames = {1, 5}},
    left_down = {frames = {1, 6}},
    down = {frames = {1, 7}},
    right_down = {frames = {1, 8}},
}

table.insert(output, {
    filename = "Truck1.png",
    name = "truck",
    grid = {size = {50, 26}},
    animations = {
        idle = {frames = {1, 1}},
        move = {frames = {1, "1-4"}},
        idle_empty = {frames = {2, 1}},
        move_empty = {frames = {2, "1-4"}}
    },
    current_animation = "idle"
})

table.insert(output, {
    filename = "DroneScout1.png",
    name = "drone",
    grid = {size = {23, 21}},
    animations = {
        left = {frames = {1, 1}},
        front = {frames = {2, 1}}
    },
    current_animation = "left"
})

table.insert(output, {
    filename = "TankBoss1.png",
    name = "tank_boss1_body",
    grid = {
        size = {117, 20},
        border = 4,
        offset = {-4, -4}
    },
    animations = tank_body_animations,
    current_animation = "idle"
})

table.insert(output, {
    filename = "TankBossTower1.png",
    name = "tank_boss1_tower",
    grid = {size = {123, 53}},
    animations = tank_tower_animations,
    current_animation = "left"
})

table.insert(output, {
    filename = "TankEnemyBody1.png",
    name = "tank_enemy1_body",
    grid = {
        size = {46, 20},
        border = 4,
        offset = {-4, -4}
    },
    animations = tank_body_animations,
    current_animation = "idle"
})

table.insert(output, {
    filename = "TankEnemyBody2.png",
    name = "tank_enemy2_body",
    grid = {
        size = {46, 20},
        border = 4,
        offset = {-4, -4}
    },
    animations = tank_body_animations,
    current_animation = "idle"
})

table.insert(output, {
    filename = "TankEnemyBody3.png",
    name = "tank_enemy3_body",
    grid = {
        size = {44, 20},
        border = 4,
        offset = {-4, -4}
    },
    animations = tank_body_animations,
    current_animation = "idle"
})

table.insert(output, {
    filename = "TankEnemyBody4.png",
    name = "tank_enemy4_body",
    grid = {
        size = {48, 20},
        border = 4,
        offset = {-4, -4}
    },
    animations = tank_body_animations,
    current_animation = "idle"
})

table.insert(output, {
    filename = "TankEnemyBody5.png",
    name = "tank_enemy5_body",
    grid = {
        size = {46, 20},
        border = 4,
        offset = {-4, -4}
    },
    animations = tank_body_animations,
    current_animation = "idle"
})

table.insert(output, {
    filename = "TankEnemyBody6.png",
    name = "tank_enemy6_body",
    grid = {
        size = {44, 20},
        border = 4,
        offset = {-4, -4}
    },
    animations = tank_body_animations,
    current_animation = "idle"
})

table.insert(output, {
    filename = "TankEnemyBody7.png",
    name = "tank_enemy7_body",
    grid = {
        size = {46, 20},
        border = 4,
        offset = {-4, -4}
    },
    animations = tank_body_animations,
    current_animation = "idle"
})

table.insert(output, {
    filename = "TankEnemyBody8.png",
    name = "tank_enemy8_body",
    grid = {
        size = {45, 20},
        border = 4,
        offset = {-4, -4}
    },
    animations = tank_body_animations,
    current_animation = "idle"
})

table.insert(output, {
    filename = "TankEnemyBody9.png",
    name = "tank_enemy9_body",
    grid = {
        size = {46, 20},
        border = 4,
        offset = {-4, -4}
    },
    animations = tank_body_animations,
    current_animation = "idle"
})

table.insert(output, {
    filename = "TankEnemyTower1.png",
    name = "tank_enemy1_tower",
    grid = {size = {49, 31}},
    animations = tank_tower_animations,
    current_animation = "left"
})

table.insert(output, {
    filename = "TankEnemyTower3.png",
    name = "tank_enemy3_tower",
    grid = {size = {44, 30}},
    animations = tank_tower_animations,
    current_animation = "left"
})

table.insert(output, {
    filename = "TankEnemyTower4.png",
    name = "tank_enemy4_tower",
    grid = {size = {49, 31}},
    animations = tank_tower_animations,
    current_animation = "left"
})

table.insert(output, {
    filename = "TankEnemyTower5.png",
    name = "tank_enemy5_tower",
    grid = {size = {49, 31}},
    animations = tank_tower_animations,
    current_animation = "left"
})

table.insert(output, {
    filename = "TankEnemyTower6.png",
    name = "tank_enemy6_tower",
    grid = {size = {49, 31}},
    animations = tank_tower_animations,
    current_animation = "left"
})

table.insert(output, {
    filename = "TankEnemyTower7.png",
    name = "tank_enemy7_tower",
    grid = {size = {49, 31}},
    animations = tank_tower_animations,
    current_animation = "left"
})

table.insert(output, {
    filename = "TankEnemyTower8.png",
    name = "tank_enemy8_tower",
    grid = {size = {49, 31}},
    animations = tank_tower_animations,
    current_animation = "left"
})

return output