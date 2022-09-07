<?php

namespace App\Http\Controllers;

use App\Character;
use App\Hud;
use App\Titler;
use Illuminate\Http\Request;

class CharacterController extends Controller
{

    public function getCharacters($id)
    {
        try {
            $characters = Character::where('hudid', $id)->get();
            if(!$characters->isEmpty())
            {
                $namelist['name'] = [];
                $namelist['characters'] = [];
                foreach($characters as $ch) {
                    $namelist['name'][] = $ch->name;
                    $namelist['characters'][] = $ch;
                }
                $namelist['key'] = 'getcharacters';
                return response()->json($namelist, 201);
            }

            return response('No Characters on Hud', 403);
        } catch(\Throwable $e) {
            return $this->generateErrorMessage($e);               
        }        
    }

    public function getCharacterData($id, $name)
    {        
        try {
            $character = Character::where('hudid', $id)->where('name',$name)->first();
            if(!empty($character)) {
                $character['key'] = 'getcharacter';
                return response()->json($character, 201);
            }

            return response('Character Does not exist', 403);
        } catch(\Throwable $e) {
            return $this->generateErrorMessage($e);                
        }        
    }

    public function getActiveCharacter($id) 
    {
        try {
            $character = Character::where('id', $id)->first();
            $character['key'] = 'getactivecharacter'; 
            if(!empty($character)) {   
                            
                return response()->json($character, 201);
            }

            return response()->json($character, 403);
        } catch(\Throwable $e) {
            return $this->generateErrorMessage($e);                
        }         
    }

    public function enableTitler($cid) 
    {
        try {
            $character = Character::where('id', $cid)->first();
            if(!empty($character)) {
                $character->update(["titler_active"=>1]);
                return response()->json($character, 200);
            }
            return response('Character Does not exist', 403);
        } catch(\Throwable $e) {
            return $this->generateErrorMessage($e);                
        }
    }

    public function disableTitler($cid) 
    {
        try {
            $character = Character::where('id', $cid)->first();
            if(!empty($character)) {
                $character->update(["titler_active"=>0]);
                return response()->json($character, 200);
            }
            return response('Character Does not exist', 403);
        } catch(\Throwable $e) {
            return $this->generateErrorMessage($e);                
        }        
    }    

    public function create(Request $request)
    {
        try {
            $result = json_decode($request->getContent());
            $character = Character::where('hudid', $result->hudid)->where('name',$result->name)->first();
            if(empty($character)) {
                $character = Character::create($request->all());
            }

            return response()->json($character, 201);
        } catch(\Throwable $e) {
            return $this->generateErrorMessage($e);                
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
            return $this->generateErrorMessage($e);                
        }        
    }

    public function delete($id, $cid)
    {
        try {
            $result = Character::where('hudid', $id)->where('id',$cid)->delete();
            if($result) {
                Hud::where('id', $id)->where('active_character',$cid)->update(['active_character'=>0]);
                Titler::where('character',$cid)->delete();
                return response("Deleated", 200);
            } else {
                return response("Delete Failure", 500);
            }
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