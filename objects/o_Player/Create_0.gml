

// Sterowanie
rot = image_angle;
image_angle = 0; // resetujemy bo nie chcemy obracać maski kolizji
rot_spd = 9;

armature = undefined;

// Debug view stuff
debug_watch = "";
debug_show_bones = false;
dbg_player = dbg_view("Player", true, 32, 128);
dbg_checkbox(ref_create(id, "debug_show_bones"), "Draw armature system");
dbg_text(ref_create(id, "debug_watch"));
