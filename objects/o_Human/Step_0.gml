event_inherited();

if ( control_level == AI_LEVEL.Human )
{
    bn_torso.rotate_towards(mouse_x, mouse_y, 0.06);
    bn_head.rotate_towards(mouse_x, mouse_y, 0.13);
    bn_arm_L_high.rotate_set_local(-35);
    bn_arm_L_low.rotate_set_local(-15);
    
    bn_arm_R_low.rotate_towards(mouse_x, mouse_y, 0.13);
    bn_arm_R_high.rotate_set_local(45);
}