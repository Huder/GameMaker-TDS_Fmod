var move_vec_x = 0;
var move_vec_y = 0;

if ( control_level == AI_LEVEL.Human )
{
    bn_torso.rotate_towards(mouse_x, mouse_y, 0.075);
    bn_head.rotate_towards(mouse_x, mouse_y, 0.15);
    
    var vecX = keyboard_check(ord("D"))-keyboard_check(ord("A"));
    var vecY = keyboard_check(ord("S"))-keyboard_check(ord("W"));
    
    if ( vecX != 0 || vecY != 0 )
    {
        var move_dir = point_direction(0, 0, vecX, vecY)-o_Cam.cam_angle;
        move_vec_x += lengthdir_x(body_move_speed, move_dir);
        move_vec_y += lengthdir_y(body_move_speed, move_dir);
    }
    
    // normalizacja
    var move_spd = point_distance(0, 0, move_vec_x, move_vec_y);
    if ( move_spd > body_move_speed )
    {
        var move_mult = body_move_speed/move_spd;
        move_vec_x *= move_mult;
        move_vec_y *= move_mult;
        move_spd = body_move_speed; // speed after normalization
    }

    // obrót postaci
    if ( !keyboard_check(vk_shift) )
    {
        var target_dir = point_direction(x, y, mouse_x, mouse_y);
        var sway_offset = 0;
        
        if ( move_spd > 0 )
        {
            body_walk_sin += move_spd*0.06; 
            sway_offset = sin(body_walk_sin)*15;
        }
        
        rotation += angle_difference(target_dir+sway_offset, rotation)*0.05;
    }
    
    if ( mouse_check_button(mb_right) )
        bn_arm_R_high.solve_ik_2(mouse_x, mouse_y, -1)
    
    if ( mouse_check_button(mb_left) )
        bn_arm_L_high.solve_ik_2(mouse_x, mouse_y, -1)
}


x += move_vec_x;
y += move_vec_y;




