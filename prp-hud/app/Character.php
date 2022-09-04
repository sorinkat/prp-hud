<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class Character extends Model
{
    protected $table = 'character';

    protected $fillable = [
        'hudid', 'name', 'commandchannel','combatanimations','socialanimations','rpanimations','titler_active'
    ];

    protected $appends = ['titlers','activetitler'];


    public function getTitlersAttribute()
    {
        $titlers = $this->hasMany(Titler::class,'character','id')->get();  
        return $titlers;
    }

    public function getActiveTitlerAttribute()
    {
        $titler = $this->hasOne(Titler::class,'character','id')->where('active',1)->first();  
        return $titler;        
    }

    protected $hidden = [];
}