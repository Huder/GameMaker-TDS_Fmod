enum CRV_ARM {linear, linear_smooth, fast_in, fast_out}

/// @desc Create armature system
function armature_system(LerpIndex=CRV_ARM.linear_smooth) constructor
{
    par = other;
    parID = par.id;
    
    lerp_crv_names = ["Linear", "LinearSmooth", "FastIn", "FastOut"];
    lerp_crv_index = LerpIndex;
    lerp_crv = animcurve_get_channel(crv_armature_lerps, lerp_crv_index);
    
    bones = [];
    bones_draw_order = [];
    
    /// @desc Przelicza kolejność wyświetlania kości na podstawie ich DrawPriority
    function recalculate_draw_order()
    {
        bones_draw_order = [];
        array_copy(bones_draw_order, 0, bones, 0, array_length(bones));
        
        array_sort(bones_draw_order, function(a, b) {
            return a.draw_priority-b.draw_priority;
        });
    }
    
    /// @desc Dodaje nową kość do armatury i zwraca utworzony struct
    /// @param {Asset.GMSprite} Spr         Sprite lub undefined
    /// @param {Struct.armature_bone} ParentBone Kość rodzica
    /// @param {String}        BoneName    Nazwa kości
    /// @param {Real}          StartX      X startu (lokalnie)
    /// @param {Real}          StartY      Y startu (lokalnie)
    /// @param {Real}          EndX        X końca (lokalnie)
    /// @param {Real}          EndY        Y końca (lokalnie)
    /// @param {Real}          SprScaleX   Lokalna skala sprita X
    /// @param {Real}          SprScaleY   Lokalna skala sprita Y
    /// @param {Real}          DrawPriority Priorytet rysowania (wyższy = wyżej)
    function add_bone(Spr=undefined, ParentBone=-1, BoneName="default", StartX=0, StartY=0, EndX=0, EndY=0, SprScaleX=1, SprScaleY=1, DrawPriority=0)
    {
        var bone = new armature_bone(Spr, ParentBone, BoneName, StartX, StartY, EndX, EndY, self, SprScaleX, SprScaleY, DrawPriority);
        array_push(bones, bone);
        recalculate_draw_order();
        return bone;
    }
    
    /// @desc Pętla Step armatury
    function Step()
    {
        for ( var i = 0; i < array_length(bones); i++ )
        {
            var bone = bones[i];
            bone.Step();
        }
    }
    
    /// @desc Pętla Draw armatury
    function Draw()
    {
        for ( var i = 0; i < array_length(bones_draw_order); i++ )
        {
            var bone = bones_draw_order[i];
            bone.Draw();
        }
    }
    
    function toString()
    {
        var bone_watch = "";
        for ( var i = 0; i < array_length(bones); i++ )
        {
            bone_watch += $"{bones[i].toString()}\n\n";
        }
        
        return  $"Armature sys: OBJ: {object_get_name(par.object_index)}, ID: {real(parID)}\n"+
                $"   World position: [{parID.x}, {parID.y}]\n"+
                $"   World rotation and scale: {parID.rotation} deg, [{parID.image_xscale}, {parID.image_yscale}]\n\n"+
                $"{bone_watch}\n";
    }
}

/// @desc Create armature bone
/// @param {Asset.GMSprite} Spr         Sprite lub undefined
/// @param {Struct.armature_bone} ParentBone Kość rodzica
/// @param {String}        BoneName    Nazwa kości
/// @param {Real}          StartX      X startu (lokalnie)
/// @param {Real}          StartY      Y startu (lokalnie)
/// @param {Real}          EndX        X końca (lokalnie)
/// @param {Real}          EndY        Y końca (lokalnie)
/// @param {Struct.armature_system} System System armatury
/// @param {Real}          SprScaleX   Lokalna skala sprita X
/// @param {Real}          SprScaleY   Lokalna skala sprita Y
/// @param {Real}          Priority    Priorytet rysowania (wyższy = wyżej)
function armature_bone(Spr=undefined, ParentBone=-1, BoneName="default", StartX=0, StartY=0, EndX=0, EndY=0, System=-1, SprScaleX=1, SprScaleY=1, Priority=0) constructor
{
    par_sys = System;
    par_bone = ParentBone;
    name = BoneName;
    
    spr = Spr;
    spr_scaleX = SprScaleX;
    spr_scaleY = SprScaleY;
    draw_priority = Priority;
    
    // Flagi konfiguracji kości
    can_stretch = true;         // Flaga oznaczająca czy przypisany sprite może się rozciągać
    inherit_rotation = true;    // Flaga oznaczająca czy dana kość dziedziczy rotację po rodzicu
    
    // Pozycja początkowa i końcowa
    base_pos_start_x = StartX;
    base_pos_start_y = StartY;
    base_pos_end_x   = EndX;
    base_pos_end_y   = EndY;
    
    base_length = point_distance(base_pos_start_x, base_pos_start_y, base_pos_end_x, base_pos_end_y);
    base_rot    = point_direction(base_pos_start_x, base_pos_start_y, base_pos_end_x, base_pos_end_y);
    
    world_x = 0;
    world_y = 0;
    world_x_end = 0;
    world_y_end = 0;
    world_rot = base_rot;
    
    local_x = 0;
    local_y = 0;
    local_x_end = 0;
    local_y_end = 0;
    local_rot = 0;

    has_sprite = (spr != undefined && sprite_exists(spr));
    sys_uses_rotation = variable_instance_exists(par_sys.parID, "rotation");

    // Zmienne do ograniczeń Constraints
    has_length_constraint = false;
    constraint_length_min = 0;
    constraint_length_max = 0;
    
    has_rot_constraint = false;
    constraint_rot_min = 0;
    constraint_rot_max = 0;
    
    // Metody umożliwiające chainowanie
    
    /// @desc Ustawianie ograniczenia długości
    function set_length_constraint(Min, Max)
    {
        has_length_constraint = true;
        constraint_length_min = Min;
        constraint_length_max = Max;
        return self;
    }
    
    /// @desc Ustawianie ograniczenia rotacji
    function set_rotation_constraint(Min, Max)
    {
        has_rot_constraint = true;
        constraint_rot_min = Min;
        constraint_rot_max = Max;
        return self;
    }
    
    /// @desc Ustaw flage rozciągania przypisanego sprite
    function set_stretch(Stretch)
    {
        can_stretch = Stretch;
        return self;
    }
    
    /// @desc Ustaw flage dziedziczenia rotacji po rodzicu
    function set_inherit_rotation(Inherit)
    {
        inherit_rotation = Inherit;
        return self;
    }
    
    /// @desc Obraca kość w kierunku podanego punktu w przestrzeni świata (uwzględniając ograniczenia i interpolację)
    /// @param {Real} World_x Pozycja docelowa X
    /// @param {Real} World_y Pozycja docelowa Y
    /// @param {Real} LerpAmount Wartość od 0 do 1 (domyślnie 1) określająca siłę obrotu w tej klatce
    function rotate_towards(World_x, World_y, LerpIndex=0.25)
    {
        var target_world_rot = point_direction(world_x, world_y, World_x, World_y);
        var diff = angle_difference(target_world_rot, world_rot);
        
        local_rot += diff*LerpIndex;
        
        if ( has_rot_constraint )
        {
            local_rot = clamp(local_rot, constraint_rot_min, constraint_rot_max);
        }
        
        return self;
    }
    
    /// @desc Dodaje rotację w przestrzeni lokalnej (uwzględnia ograniczenia)
    /// @param {Real} Angle Kąt o jaki obrócić kość
    function rotate_local(Angle)
    {
        local_rot += Angle;
        if ( has_rot_constraint ) local_rot = clamp(local_rot, constraint_rot_min, constraint_rot_max);
        return self;
    }
    
    /// @desc Dodaje rotację w przestrzeni świata (uwzględnia flipowanie systemu i ograniczenia)
    /// @param {Real} Angle Kąt o jaki obrócić kość (world-space)
    function rotate_world(Angle)
    {
        var sys_obj = par_sys.parID;
        local_rot += Angle*sign(sys_obj.image_xscale)*sign(sys_obj.image_yscale);
        if ( has_rot_constraint ) local_rot = clamp(local_rot, constraint_rot_min, constraint_rot_max);
        return self;
    }
    
    /// @desc Ustawia rotację w przestrzeni lokalnej (uwzględnia ograniczenia)
    /// @param {Real} Angle Docelowy kąt w przestrzeni lokalnej
    function rotate_set_local(Angle)
    {
        local_rot = Angle;
        if ( has_rot_constraint ) local_rot = clamp(local_rot, constraint_rot_min, constraint_rot_max);
        return self;
    }
    
    /// @desc Ustawia rotację tak, aby kość w świecie gry wskazywała podany kąt (uwzględnia mirroring i ograniczenia)
    /// @param {Real} Angle Docelowy kąt w przestrzeni świata
    function rotate_set_world(Angle)
    {
        var sys_obj = par_sys.parID;
        var sx = sign(sys_obj.image_xscale);
        var sy = sign(sys_obj.image_yscale);
        
        // Docelowa rotacja "logicza" w design-space
        var target_world_rot = Angle * sx * sy;
        
        // Wyznaczamy aktualny bazowy kąt (punkt odniesienia w zależności od hierarchii)
        var sys_rot = par_sys.sys_uses_rotation ? sys_obj.rotation : sys_obj.image_angle;
        var anchor_rot = (par_bone != -1 && inherit_rotation) ? par_bone.world_rot : sys_rot;
        
        // Obliczamy wymaganą lokalną rotację (korzystamy z angle_difference by uniknąć przeskoków)
        local_rot = angle_difference(target_world_rot, anchor_rot + base_rot);
        
        if ( has_rot_constraint ) local_rot = clamp(local_rot, constraint_rot_min, constraint_rot_max);
        return self;
    }
    
    /// @desc Pętla Step kości
    function Step()
    {
        // Zastosowanie ograniczeń rotacji
        if ( has_rot_constraint )
        {
            local_rot = clamp(local_rot, constraint_rot_min, constraint_rot_max);
        }
        
        // Pobranie parametrów systemu armatury
        var sys_obj = par_sys.parID;
        var sys_rot = sys_uses_rotation ? sys_obj.rotation : sys_obj.image_angle; 
        var sys_sx = sys_obj.image_xscale;
        var sys_sy = sys_obj.image_yscale;

        // Obliczenia transformacji w relacji - Forward Kinematics (Local Space)
        if ( par_bone != -1 )
        {
            // Dziedziczenie rotacji po rodzicu lub nie
            if ( inherit_rotation )
            {
                // world_rot = Rodzic + kąt_bazy_kości + lokalne_wychylenie (relatywne)
                world_rot = par_bone.world_rot + base_rot + local_rot;
            }
            else
            {
                // world_rot = kąt_bazy_systemu + kąt_bazy_kości + lokalne_wychylenie
                world_rot = sys_rot + base_rot + local_rot;
            }
            
            // Obliczamy pozycję startową relatywnie do układu współrzędnych rodzica (Local Offset)
            var rx = base_pos_start_x*sys_sx+local_x;
            var ry = base_pos_start_y*sys_sy+local_y;
            
            var dist = point_distance(0, 0, rx, ry);
            // Dodajemy obrót rodzica, aby wyznaczyć pozycję w świecie
            var dir  = par_bone.world_rot + point_direction(0, 0, rx, ry);
            
            world_x = par_bone.world_x+lengthdir_x(dist, dir);
            world_y = par_bone.world_y+lengthdir_y(dist, dir);
        }
        else
        {
            // Brak kości nadrzędnej = korzeń systemu (root bone) przypięty do obiektu
            world_rot = sys_rot+base_rot+local_rot;
            
            var rx = (base_pos_start_x+local_x)*sys_sx;
            var ry = (base_pos_start_y+local_y)*sys_sy;
            
            var dist = point_distance(0, 0, rx, ry);
            var dir  = point_direction(0, 0, rx, ry) + sys_rot;
            
            world_x = sys_obj.x+lengthdir_x(dist, dir);
            world_y = sys_obj.y+lengthdir_y(dist, dir);
        }
        
        // Wyliczamy punkt końcowy w przestrzeni świata (read-only)
        world_x_end = world_x+lengthdir_x(base_length*sys_sx, world_rot);
        world_y_end = world_y+lengthdir_y(base_length*sys_sx, world_rot);
        
        // Wyliczamy lokalny punkt końcowy w przestrzeni rodzica
        var loc_rot = base_rot+local_rot;
        local_x_end = rx+lengthdir_x(base_length*sys_sx, loc_rot);
        local_y_end = ry+lengthdir_y(base_length*sys_sx, loc_rot);
    }
    
    /// @desc Pętla Draw kości
    function Draw()
    {
        if ( has_sprite ) 
        {
            var sys_obj = par_sys.parID;
            
            var draw_sx = sys_obj.image_xscale*spr_scaleX;
            var draw_sy = sys_obj.image_yscale*spr_scaleY;
            var draw_rot = world_rot*sign(sys_obj.image_xscale)*sign(sys_obj.image_yscale);
            draw_sprite_ext(spr, 0, world_x, world_y, draw_sx, draw_sy, draw_rot, c_white, 1.0);
        }
    }
    
    function toString()
    {
        return  $"Bone: {name}\n"+
                $"   World Start: [{world_x}, {world_y}], End: [{world_x_end}, {world_y_end}], Rot: {world_rot} deg\n"+
                $"   Local Start: [{local_x}, {local_y}], End: [{local_x_end}, {local_y_end}], Rot: {local_rot} deg\n"+
                $"   Base Start: [{base_pos_start_x}, {base_pos_start_y}], End: [{base_pos_end_x}, {base_pos_end_y}], {base_rot} deg\n"+
                $"   Stretch: {(can_stretch ? "Yes" : "No")}, Inherit Rot: {(inherit_rotation ? "Yes" : "No")}\n";
    }
}



