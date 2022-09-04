<?php

/** @var \Laravel\Lumen\Routing\Router $router */

/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
|
| Here is where you can register all of the routes for an application.
| It is a breeze. Simply tell Lumen the URIs it should respond to
| and give it the Closure to call when that URI is requested.
|
*/

$router->get('/', function () use ($router) {
    return $router->app->version();
});

$router->group(['prefix'=>'api'], function () use ($router) {
    $router->get('hud', ['uses' => 'HudController@getHuds']);
    $router->get('hud/{id}', ['uses' => 'HudController@getHudData']);
    $router->post('hud', ['uses' => 'HudController@create']);
    $router->delete('hud/{id}', ['uses' => 'HudController@delete']);
    $router->put('hud/{id}', ['uses' => 'HudController@update']);    

    $router->get('character/{id}', ['uses' => 'CharacterController@getCharacters']);
    $router->get('character/{id}/{name}', ['uses' => 'CharacterController@getCharacterData']);
    $router->post('character', ['uses' => 'CharacterController@create']);
    $router->delete('character/{id}/{name}', ['uses' => 'CharacterController@delete']);
    $router->put('character/{id}/{name}', ['uses' => 'CharacterController@update']); 
    
    //$router->get('titler/{id}', ['uses' => 'CharacterController@getCharacters']);
    //$router->get('titler/{id}/{name}', ['uses' => 'CharacterController@getCharacterData']);
    $router->get('titler/{cid}', ['uses' => 'TitlerController@get']);
    $router->post('titler', ['uses' => 'TitlerController@create']);
    $router->delete('titler/{id}', ['uses' => 'TitlerController@delete']);
    $router->put('titler/{id}', ['uses' => 'TitlerController@update']);

    // Enables the selected hud and disables all others.  Pass in 0 to disable all huds for character.
    $router->put('titler/{cid}/{hud}', ['uses' => 'TitlerController@changeState']);  
    $router->put('titler/{cid}/enable', ['uses' => 'CharacterController@enableTitler']);    
    $router->put('titler/{cid}/disable', ['uses' => 'CharacterController@disableTitler']);
           
}); 