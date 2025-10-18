<?php

require_once "get.model.php";

class Connection{

        /*=============================================
        Información de la base de datos
        =============================================*/

        static public function infoDatabase(){

                // Load configuration from environment variables
                // If config.env.php exists (created by docker-entrypoint.sh), use it
                $configFile = __DIR__ . '/../../config.env.php';
                if (file_exists($configFile)) {
                        require_once $configFile;
                }

                $infoDB = array(
                        "database" => getenv('DB_DATABASE') ?: (defined('DB_DATABASE') ? DB_DATABASE : ""),
                        "user" => getenv('DB_USER') ?: (defined('DB_USER') ? DB_USER : ""),
                        "pass" => getenv('DB_PASSWORD') ?: (defined('DB_PASSWORD') ? DB_PASSWORD : "")
                );

                return $infoDB;

        }

        /*=============================================
        APIKEY
        =============================================*/

        static public function apikey(){

                // Load configuration from environment variables
                $configFile = __DIR__ . '/../../config.env.php';
                if (file_exists($configFile)) {
                        require_once $configFile;
                }

                $apiKey = getenv('API_KEY') ?: (defined('API_KEY') ? API_KEY : "sdfgsdgdsfgh4356e45rdfhdfgh5rdfhfgjrtrer");
                
                return $apiKey;

        }

        /*=============================================
        Acceso público
        =============================================*/
        
        static public function publicAccess(){

                $tables = [""];

                return $tables;

        }

        /*=============================================
        Conexión a la base de datos
        =============================================*/

        static public function connect(){


                try{

                        // Get database host from environment variables
                        $dbHost = getenv('DB_HOST') ?: (defined('DB_HOST') ? DB_HOST : 'localhost');
                        $dbPort = getenv('DB_PORT') ?: (defined('DB_PORT') ? DB_PORT : '3306');

                        $link = new PDO(
                                "mysql:host=".$dbHost.";port=".$dbPort.";dbname=".Connection::infoDatabase()["database"],
                                Connection::infoDatabase()["user"], 
                                Connection::infoDatabase()["pass"]
                        );

                        $link->exec("set names utf8mb4");

                }catch(PDOException $e){

                        die("Error: ".$e->getMessage());

                }

                return $link;

        }

        /*=============================================
        Validar existencia de una tabla en la bd
        =============================================*/

        static public function getColumnsData($table, $columns){

                /*=============================================
                Traer el nombre de la base de datos
                =============================================*/

                $database = Connection::infoDatabase()["database"];

                /*=============================================
                Traer todas las columnas de una tabla
                =============================================*/

                $validate = Connection::connect()
                ->query("SELECT COLUMN_NAME AS item FROM information_schema.columns WHERE table_schema = '$database' AND table_name = '$table'")
                ->fetchAll(PDO::FETCH_OBJ);

                /*=============================================
                Validamos existencia de la tabla
                =============================================*/

                if(empty($validate)){

                        return null;

                }else{

                        /*=============================================
                        Ajuste de selección de columnas globales
                        =============================================*/

                        if($columns[0] == "*"){
                                
                                array_shift($columns);

                        }

                        /*=============================================
                        Validamos existencia de columnas
                        =============================================*/

                        $sum = 0;
                                
                        foreach ($validate as $key => $value) {

                                $sum += in_array($value->item, $columns);       
                                
                                                
                        }



                        return $sum == count($columns) ? $validate : null;
                        
                        
                        
                }

        }

        /*=============================================
        Generar Token de Autenticación
        =============================================*/

        static public function jwt($id, $email){

                $time = time();

                $token = array(

                        "iat" =>  $time,//Tiempo en que inicia el token
                        "exp" => $time + (60*60*24), // Tiempo en que expirará el token (1 día)
                        "data" => [

                                "id" => $id,
                                "email" => $email
                        ]

                );

                return $token;
        }

        /*=============================================
        Validar el token de seguridad
        =============================================*/

        static public function tokenValidate($token,$table,$suffix){

                /*=============================================
                Traemos el usuario de acuerdo al token
                =============================================*/
                $user = GetModel::getDataFilter($table, "token_exp_".$suffix, "token_".$suffix, $token, null,null,null,null);
                
                if(!empty($user)){

                        /*=============================================
                        Validamos que el token no haya expirado
                        =============================================*/ 

                        $time = time();

                        if($time < $user[0]->{"token_exp_".$suffix}){

                                return "ok";

                        }else{

                                return "expired";
                        }

                }else{

                        return "no-auth";

                }

        }

}