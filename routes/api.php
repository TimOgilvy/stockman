<?php

use Illuminate\Http\Request;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::middleware('auth:api')->get('/user', function (Request $request) {
    return $request->user();
});

// insecure testing api stuff
Route::get('/tasks', function (App\Task $tasks) {
    $data = $tasks::orderBy('created_at', 'asc')->get();
    return response()->json($data, 200, array(), JSON_PRETTY_PRINT);
});
