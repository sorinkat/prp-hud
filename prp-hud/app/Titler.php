<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class Titler extends Model

{

    protected $table = 'titler';
    public $incrementing = false;

    protected $fillable = [
        'id', 'character', 'title','text','active'
    ];


    protected $hidden = [];
}