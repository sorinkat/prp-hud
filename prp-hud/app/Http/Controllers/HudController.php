<?php

namespace App\Http\Controllers;

use App\Hud;
use Illuminate\Http\Request;

class HudController extends Controller
{
    public function getHuds()
    {
        $huds = Hud::all();
        if(!empty($huds))
        {
            return response()->json($huds, 201);
        }

        return response('No Huds', 403);        
    }

    public function getHudData($id)
    {
        $hud = Hud::find($id);
        if(!empty($hud) && $hud->active == 1) {
            return response()->json($hud, 201);
        }
        elseif(!empty($hud) && $hud->active != 1) {
            return response('Hud Disabled', 403);
        }
        return response('Hud Does not exist', 403);
    }

    public function create(Request $request)
    {
        $hud = Hud::create($request->all());

        return response()->json($hud, 201);
    }

    public function update($id, Request $request)
    {
        $hud = Hud::findOrFail($id);
        $hud->update($request->all());

        return response()->json($hud, 200);
    }

    public function delete($id)
    {
        Hud::findOrFail($id)->delete();
        return response('Deleted Successfully', 200);
    }    
}