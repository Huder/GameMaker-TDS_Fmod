
if ( debug_draw_armature && armature != undefined )
{
    draw_set_color(c_red);
    var b_list = armature.bones;
    var b_count = array_length(b_list);
    
    for ( var i = 0; i < b_count; i++ )
    {
        var b = b_list[i];
        
        // Rysujemy linię kości (od początku do końca)
        draw_line(b.world_x, b.world_y, b.world_x_end, b.world_y_end);
        
        // Rysujemy kółko na końcu kości (średnica 3px -> radius 1.5)
        draw_circle(b.world_x_end, b.world_y_end, 1.5, false);
        
        // Opcjonalnie: mały punkt na początku kości (joint)
        draw_circle(b.world_x, b.world_y, 0.5, true);
    }
    
    // Rysujemy origin całego obiektu
    draw_set_color(c_yellow);
    draw_circle(x, y, 2, false);
    
    draw_set_color(c_white); // Reset koloru
}