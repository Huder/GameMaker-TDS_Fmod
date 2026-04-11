
// Obrót postacią - crtl zablokuj
if ( !keyboard_check(vk_control) )
{
    var toMouseAngle = angle_difference(point_direction(x, y, mouse_x, mouse_y), rot);
    var absAngle = abs(toMouseAngle);
    
    if ( absAngle > 0.015 )
    {
        rot += min(absAngle, rot_spd)*sign(toMouseAngle);
    }
}