<?php

    header("Access-Control-Allow-Origin: *");
    header("Content-Type: application/json; charset=UTF-8");
    header('Content-Type: application/json');

    use PHPMailer\PHPMailer\PHPMailer;
    use PHPMailer\PHPMailer\Exception;
    require_once 'PHPMailer/src/Exception.php';
    require_once 'PHPMailer/src/PHPMailer.php';
    require_once 'PHPMailer/src/SMTP.php';


    // Enable error reporting
    error_reporting(E_ALL);
    ini_set('display_errors', 1);

    // Import PHPMailer classes into the global namespace

    function Mandar_Mail($email, $sbj, $bd)
	{
		
       		$mail = new PHPMailer(true);
		try{
            $mail->isSMTP();
            $mail->Host = 'smtp.gmail.com';
            $mail->SMTPAuth = true;
            $mail->Username = 'appbarepvc@gmail.com';
            $mail->Password = 'cfzd dtct vwdj ioxz';  // Sua senha de e-mail
            $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
            $mail->Port = 587;

            $mail->setFrom('appbarepvc@gmail.com', 'Sado Team'); // This should match your Gmail address
            $mail->addAddress($email, "Teste"); // Ensure $email is valid and not empty

            $mail->isHTML(true);
            $mail->CharSet = 'UTF-8';
            $mail->Subject = $sbj;
            $mail->Body = $bd;

            if (!$mail->send()) 
            {
                echo 'Não foi possível enviar o e-mail. Erro: ' . $mail->ErrorInfo;
            } 
            else 
            {
                echo json_encode(['success' => true]);
            }
        } 
        catch (Exception $e) 
        {
            echo "Erro ao enviar e-mail: {$mail->ErrorInfo}";
        }
    }

?>
