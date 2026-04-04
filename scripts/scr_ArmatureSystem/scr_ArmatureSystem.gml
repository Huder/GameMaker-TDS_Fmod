function armature_Sys(Rot) constructor 
{
    root_other = other;
    root_instance = other.id;
    
    root_x = root_instance.x;
    root_y = root_instance.y;
    root_rotation = Rot;
    root_depth = root_instance.depth;
    
    bones = []; // lista id instancji kości
    
    /// @desc Funkcja pomocnicza ustalająca depth kości
    function __recalculate_draw_order()
    {
        var b_num = array_length(bones);
        for ( var i = 0; i < b_num; i++ )
        {
            var bone = bones[i];
            var priority = bone.bone_drawPriority;
            bone.bone_depth = root_depth; // TODO
        }
    }
    
    /// @desc Ustawia obrót systemu
    /// @param      {Real}      Rot      Kąt obrotu całego systemu armatury
    function Set_Rotation(Rot)
    {
        root_rotation = Rot;
    }
    
    /// @desc Dodaje obrót systemu
    /// @param      {Real}      Rot      Kąt obrotu całego systemu armatury
    function Add_Rotation(Rot)
    {
        root_rotation += Rot;
    }
    
    /// @desc Dodaje nową kość do armatury i zwraca id instancji kości
    /// @param {Asset.GMSprite}         Spr             Sprite lub -1 gdy nie ma mieć sprita
    /// @param {Asset.GMSprite}         Mask            Sprite Maski lub -1 gdy ma mieć taką jak sprite_index
    /// @param {String}                 BoneName        Nazwa kości
    /// @param {String}                 BoneParentName  Nazwa kości rodzica do którego ta kość jest podłączona (nie musi być)
    /// @param {Real}                   StartX          X startu (lokalne)
    /// @param {Real}                   StartY          Y startu (lokalne)
    /// @param {Real}                   EndX            X końca (lokalne)
    /// @param {Real}                   EndY            Y końca (lokalne)
    /// @param {Real}                   SprScaleX       Lokalna skala sprita X
    /// @param {Real}                   SprScaleY       Lokalna skala sprita Y
    /// @param {Real}                   DrawPriority    Priorytet rysowania 
    function Add_Bone(Spr=-1, Mask=-1, BoneName="default", BoneParentName="", StartX=0, StartY=0, EndX=32, EndY=0, SprScaleX=1, SprScaleY=1, DrawPriority=0)
    {
        
        var ind = instance_create_depth(root_x, root_y, root_depth-1, ARMATURE_BONE, { 
                sprite_index : Spr,
                mask_index : Mask,
                parent_system : other,
                system_instance : root_instance,
                bone_name : BoneName,
                bone_drawPriority: DrawPriority
            });
        
        if ( BoneParentName != "" && BoneParentName != BoneName )
        {
            // wyszukaj id instancji wskazanego bone po jego nazwie z listy bones systemu
            var b_num = array_length(bones);
            for ( var i = 0; i < b_num; i++ )
            {
                var bone = bones[i];
                if ( bone.bone_name == BoneParentName )
                {
                    ind.parent_bone = bone;
                    break;
                }
            }
        }
        else 
        {
        	ind.parent_bone = undefined;
        }
        
        show_message(ind.parent_bone)
        
        array_push(bones, ind);
        __recalculate_draw_order();
        with (ind) armature_BoneStep();
    }
    
    /// @function Step()
    function Step()
    {
        root_x = root_instance.x;
        root_y = root_instance.y;
        root_depth = root_instance.depth;
        
        var b_num = array_length(bones);
        for ( var i = 0; i < b_num; i++ )
        {
            with ( bones[i] )
            {
                armature_BoneStep();
            }
        }
    }
    
    /// @function Draw_debug()
    function Draw_debug()
    {
        var b_num = array_length(bones);
        for ( var i = 0; i < b_num; i++ )
        {
            
        }
    }
    
    
    function toString()
    {
        var bonesList = "[ ";
        var b_num = array_length(bones);
        for ( var i = 0; i < b_num; i++ )
        {
            var bone = bones[i];
            if ( instance_exists(bone) )
            {
                var boneName = bone.bone_name;
                bonesList += $"{boneName}={real(bone)} ";
            }
            else 
            {
            	continue;
            }
        }
        bonesList += "]";
        
        return  $"Armature Root of object: {object_get_name(root_other.object_index)}, id: {real(root_instance)} \n"+
                $"   Position: [{root_x}, {root_y}]\n   Rotation: {root_rotation}\n"+
                $"   Depth: {root_depth}, Numb of Bones: {array_length(bones)}\n"+
                $"   Bone's Ids: {bonesList}";
    }
}


/// @desc Wykonuje kalkulację Step kości wywołaną przez armature system Step(), ta funkcja działa w scope instancji ARMATURE_BONE
function armature_BoneStep()
{
    depth = parent_system.root_depth+bone_depth;
}