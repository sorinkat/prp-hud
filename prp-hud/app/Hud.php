<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class Hud extends Model

{

    protected $table = 'hud';
    public $incrementing = false;

    protected $fillable = [
        'id', 'account', 'active','active_character'
    ];

    protected $appends = ['characterdata'];

    protected $hidden = [];

    public function getCharacterDataAttribute()
    {
        $profile = $this->hasOne(Character::class,'id','active_character')->first();  
        return $profile;
    }
}