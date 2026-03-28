event_inherited();

if ( control_level == AI_LEVEL.Human )
{
    bn_torso.rotate_towards(mouse_x, mouse_y, 0.06).rotate_local(2);
    
    bn_head.rotate_towards(mouse_x, mouse_y, 0.13);
    
    var mouse_dir = angle_difference(bn_torso.world_rot, point_direction(x, y, mouse_x, mouse_y));
    if ( mouse_dir > -45 )
        bn_arm_R_high.solve_ik_2(mouse_x, mouse_y, -1);
    
    if ( bn_arm_R_high.local_rot > 20 && bn_arm_R_low.local_rot < 38 )
        bn_arm_L_high.solve_ik_2(bn_arm_R_low.world_x_end, bn_arm_R_low.world_y_end, 1);
}
