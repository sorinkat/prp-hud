<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CharacterTitlerTracking extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('titler', function (Blueprint $table) {
            $table->increments('id');
            $table->integer('character');
            $table->string('title');
            $table->string('text');            
            $table->boolean('active');            
            $table->timestamps();
        });

        Schema::table('character', function (Blueprint $table) {
            $table->integer('titler_active')->default(0);
        });        
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('titler');
    }
}
