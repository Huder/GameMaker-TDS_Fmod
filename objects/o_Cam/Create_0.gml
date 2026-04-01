view_w = window_get_width();
view_h = window_get_height();

cam_zoom = 1;
cam_w = view_w*cam_zoom;
cam_h = view_h*cam_zoom;


cam = camera_create_view(x, y, cam_w, cam_h);
view_set_camera(0, cam);


cam_x = x;
cam_y = y;
cam_lerp = 0.25;
cam_angle = 0;


zoom_target = cam_zoom;
zoom_inc = 0.15;
zoom_min = 0.5;
zoom_max = 4;
