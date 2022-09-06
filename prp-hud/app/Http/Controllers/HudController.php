<?php

namespace App\Http\Controllers;

use App\Hud;
use Illuminate\Http\Request;

class HudController extends Controller
{
    public function getHuds()
    {
        try {
            $huds = Hud::all();
            if(!$huds->isEmpty())
            {
                return response()->json($huds, 201);
            }

            return response('No Huds', 403);    
        } catch(\Throwable $e) {
            return $this->generateErrorMessage($e);                 
        }            
    }

    public function getHudData($id)
    {
        try {
            $hud = Hud::find($id);
            $hud['key'] = 'gethud';
            if(!empty($hud) && $hud->active == 1) {
                return response()->json($hud, 201);
            }
            elseif(!empty($hud) && $hud->active != 1) {
                return response('Hud Disabled', 403);
            }
            return response('Hud Does not exist', 403);
        } catch(\Throwable $e) {
            return $this->generateErrorMessage($e);                
        }        
    }

    public function setActiveCharacter($id,$cid) {
        try {
            $hud = Hud::findOrFail($id);
            $hud->update(["active_character"=>$cid]);

            return response()->json($hud, 200);
        } catch(\Throwable $e) {
            return $this->generateErrorMessage($e);  
        }
    }

    public function create(Request $request)
    {
        try {
            $result = json_decode($request->getContent());
            $hud = Hud::find($result->id);
            if(empty($hud)) {
                $hud = Hud::create($request->all());
                $hud['key'] = 'gethud';
            }
            return response()->json($hud, 201);
        } catch(\Throwable $e) {
            return $this->generateErrorMessage($e);                 
        }
    }

    public function update($id, Request $request)
    {
        try {
            $hud = Hud::findOrFail($id);
            $hud->update($request->all());

            return response()->json($hud, 200);
        } catch(\Throwable $e) {
            return $this->generateErrorMessage($e);                
        }        
    }

    public function delete($id)
    {
        try {
            Hud::findOrFail($id)->delete();
            return response('Deleted Successfully', 200);
        } catch(\Throwable $e) {
            return $this->generateErrorMessage($e);                  
        }        
    }   

    private function generateErrorMessage($e) {
        $error = [
            'description' => $e->getMessage(),
            'trace' => $e->getTrace(),
            'lineno' => $e->getLine(),
            'file' => $e->getFile(),
        ];
    
        return response()->json([
            'error' => $e->getMessage(),
            'record' => $error,
        ], 500);      
      }    
}