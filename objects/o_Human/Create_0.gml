event_inherited();

debug_draw_armature = true;
torso_limit = 35;

bn_torso    = armature.add_bone(spr_Human_Backpack, -1, "Torso", 0, 0, 21, 0, 1, 1, 2).set_rotation_constraint(-torso_limit, torso_limit);
bn_head     = armature.add_bone(spr_Human_head, bn_torso, "Head", 0, 0, 26, 0, 1, 1, 3).set_rotation_constraint(-15, 15);
bn_arm_R_high = armature.add_bone(spr_Human_arm_R_top, bn_torso, "Arm_High_R", 0,  20, 0,  35, 1,  1, 0).set_rotation_constraint(-10, 80);
bn_arm_L_high = armature.add_bone(spr_Human_arm_R_top, bn_torso, "Arm_High_L", 0, -20, 0, -35, 1, -1, 0).set_rotation_constraint(-120, 20);
bn_arm_R_low = armature.add_bone(spr_Human_arm_R_bottom, bn_arm_R_high, "Arm_Low_R", 14, 0, 55, 0, 1,  1, 1).set_rotation_constraint(-5, 115);
bn_arm_L_low = armature.add_bone(spr_Human_arm_R_bottom, bn_arm_L_high, "Arm_Low_L", 14, 0, 55, 0, 1, -1, 1).set_rotation_constraint(-115, 5);

// phys stats
body_rot_speed = 16;
body_move_speed = 4;
body_walk_sin = 0;