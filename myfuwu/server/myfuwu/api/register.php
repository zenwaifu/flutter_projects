
<?php
	// for testing purpose only
	//echo $email;
	//echo $password;

	// testing purpose only
	//proper way of returning data in json format
	//so that flutter can easily parse the data
	//$data = array("email"=>$email, "password"=>$password);
	//echo json_encode($data);

	//--------------------------------------------------------------------------------------------

	// written JSON data from server from PHP to Flutter
	//heders to allow cross origin resource sharing from any domain to access this file
	header("Access-Control-Allow-Origin: *"); // allow access from any domain(web, mobile, flutter, etc)
	include 'dbconnect.php'; // include database connection file

	//header to specify that the data being returned is in json format
	// check if the server responds is  post array or not. one way to safeguard api
	// request only handling post requests
	// $_POST associative array that contains data sent to the script via the HTTP POST method
		//allows to access and process the data submitted by users
	// POST is more secure than GET as data is not visible in url
	if ($_SERVER['REQUEST_METHOD'] != 'POST') {
		http_response_code(405); // method not allowed
		echo json_encode(array("error"=>"Method not allowed.Only POST method is allowed"));
		exit();
	}

	//check if fields are set in post array
	if (!isset($_POST['email']) || !isset($_POST['password'])) {
		http_response_code(400); // bad request
		echo json_encode(array("error"=>" Bad request! Missing parameters"));
		exit();
	}
	//retrieve fields from post array
	$email = $_POST['email'];
	$password = $_POST['password'];
	$hashedpassword = sha1($password);
	$otp = rand(100000,999999); // generate random 6 digit otp
	
	//check if email already exists in database
	$sqlcheckmail = "SELECT * FROM `tbl_users` WHERE `user_email` ='$email'";
	$result = $conn->query($sqlcheckmail);
	if ($result->num_rows > 0) {
		$response = array('status' => 'failed', 'message' => 'Email already registered');
		sendJsonResponse($response);
		exit();
	}

	// insert new user into database
	$sqlregister = 'INSERT INTO `tbl_users` (`user_email`, `user_password`, `user_otp`) VALUES ('$email', '$hashedpassword', '$otp')';
	// execute the query and handle potential errors
	try{
		if($conn->query($sqlregister) === TRUE){
			$response = array('status' => 'success', 'message' => 'User registered successfully');
			sendJsonResponse($response);
		}else{
			// insertion failed -- possibly due to database error 
			// response -- array
			$response = array('status' => 'failed', 'message' => 'User registration failed');
			sendJsonResponse($response);
		}
	} catch (Exception $e){
		$response = array('status' => 'error', 'message' => 'Registration failed! An error occurred: ' . $e->getMessage());
		sendJsonResponse($response);
	}
	
/**
 * This function sends a response to the client in json format.
 * It sets the header as 'application/json' and then
 * uses the json_encode function to convert the array
 * into a json object and send it to the client
 * @param array $sentArray the array to be sent as a json response
 */
	function sendJsonResponse($sentArray){
		header('Content-Type: application/json');
		echo json_encode($sentArray);
	}

?>