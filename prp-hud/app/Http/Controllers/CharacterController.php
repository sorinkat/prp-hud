<?php

namespace App\Http\Controllers;

use App\Character;
use Illuminate\Http\Request;

class CharacterController extends Controller
{

    public function getCharacters($id)
    {
        try {
            $characters = Character::where('hudid', $id)->get();
            if(!$characters->isEmpty())
            {
                $namelist = [];
                foreach($characters as $ch) {
                    $namelist[] = $ch->name;
                }
                return response()->json($namelist, 201);
            }

            return response('No Characters on Hud', 403);
        } catch(\Throwable $e) {
            return response()->json($e, 500);                
        }        
    }

    public function getCharacterData($id, $name)
    {        
        try {
            $character = Character::where('hudid', $id)->where('name',$name)->first();
            if(!empty($character)) {
                return response()->json($character, 201);
            }

            return response('Character Does not exist', 403);
        } catch(\Throwable $e) {
            return response()->json($e, 500);                
        }        
    }

    public function create(Request $request)
    {
        try {
            $hud = Character::create($request->all());

            return response()->json($hud, 201);
        } catch(\Throwable $e) {
            return response()->json($e, 500);                
        }        
    }

    public function update($id, $name, Request $request)
    {
        try {
            $character = Character::where('hudid', $id)->where('name',$name)->first();
            if(!empty($character)) {
                $character->update($request->all());
                return response()->json($character, 200);
            }

            return response('Character Does not exist', 403);
        } catch(\Throwable $e) {
            return response()->json($e, 500);                
        }        
    }

    public function delete($id, $name)
    {
        try {
            $name = urldecode($name);
            $result = Character::where('hudid', $id)->where('name',$name)->delete();
            if($result) {
                return response("Deleated", 200);
            } else {
                return response("Delete Failure", 500);
            }
        } catch(\Throwable $e) {
            return response()->json($e, 500);                
        }        
    }   
}