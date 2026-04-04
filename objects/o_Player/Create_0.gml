

// Sterowanie
rot = image_angle;
image_angle = 0; // resetujemy bo nie chcemy obracać maski kolizji
rot_spd = 9;

// Inicjujemy armaturę w domyślnej pozie T-Pose
armature = new armature_Sys(rot);
armature.Add_Bone(spr_Human_Backpack, -1,   "Torso", "",        0, 0, 1,  0, 1, 1, 2);
armature.Add_Bone(spr_Human_head, -1,       "Head",  "Torso",   0, 0, 26, 0, 1, 1, 1);


// Debug view stuff
debug_watch = "";
debug_show_bones = false;
dbg_player = dbg_view("Player", true, 32, 128);
dbg_checkbox(ref_create(id, "debug_show_bones"), "Draw armature system");
dbg_text(ref_create(id, "debug_watch"));
