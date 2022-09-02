<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class Character extends Model
{
    protected $table = 'character';

    protected $fillable = [
        'hudid', 'name', 'commandchannel','combatanimations','socialanimations','rpanimations'
    ];

    protected $appends = ['titlers'];


    public function getTitlersAttribute()
    {
        $titlers = $this->hasMany(Titler::class,'id','character');  
        return $titlers;
    }

    protected $hidden = [];
}