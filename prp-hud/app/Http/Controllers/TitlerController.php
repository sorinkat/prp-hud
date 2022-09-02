<?php

namespace App\Http\Controllers;

use App\Titler;
use App\Character;
use Illuminate\Http\Request;

class TitlerController extends Controller
{
    public function changeState($cid, $hud, Request $request) {
        try {
            $titlers = Titler::where('character', $cid);
            if(!empty($titler)) {
                $titlers->update(['active' => 0]);
            }
            
            if($hud != 0) {
                $titler = Titler::where('id', $hud);
                $titler->update(['active' => 1]);
            } else {
                $titler = [];
            }
            return response()->json($titler, 200);
        } catch(\Throwable $e) {
            return $this->generateErrorMessage($e);                
        }
    }

    public function create(Request $request) {
        try {
            $result = json_decode($request->getContent());
            $titler = Titler::where('character', $result->character)->where('title',$result->title)->first();
            if(empty($titler)) {
                $titler = Titler::create($request->all());
            }

            return response()->json($titler, 201);
        } catch(\Throwable $e) {
            return $this->generateErrorMessage($e);                
        }
    }

    public function update($id, Request $request) {
        try {
            $titler = Titler::where('id', $id)->first();
            if(!empty($titler)) {
                $titler->update($request->all());
                return response()->json($titler, 200);
            }

            return response('Titler Does not exist', 403);
        } catch(\Throwable $e) {
            return $this->generateErrorMessage($e);                
        } 
    }

    public function delete($id) {
        try {
            $result = Titler::where('id', $id)->delete();
            if($result) {
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
