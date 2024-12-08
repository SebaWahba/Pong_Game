# Pong_Game
A pong game designed on FPGA Basys3 board using HDL Verilog


By:

Seba Wahba, 
Roaa,
Sondos


Project Report

We followed a modular design approach to design our arcade game. First of all we created a module to control the displaying of the content on the screen and allow us to view pixels in the form of text and pixelated shapes on the screen. In order to display text and images, we must have two other modules for the pixel generation as well as the text generation as they will follow different approaches to viewing different types of data on the monitor. For instance, in order to view text we have used hexadecimal numbers which are encoded in the ascii rom module to represent different characters, numbers and symbols as for the formation of the paddles and ball we have used the ball rom to implement the rounded figure of the ball as it may have ragged edges when you are too close to them so its figure must be represented using rom addresses to show something like this where the stars in the comments represent 1s and the spaces are represented by 0s.

To begin with, we have the "top module" which is used to collect all the modules of the game together in one module and connect them all together, then it is used to output the figures of the score on the seven segment display as well as arrange the states of the game into the new game, play and new ball when one of the players drops the ball. It is also this module’s job to run the video representation of the game when the video signal’s value is 1.  The module also initialises all the values such as d_clr which will be used to represent the condition where the score should be cleared and reset; this of course will occur upon starting of the game or when the reset button is pressed.
	
Another module is the "score_counter' which is essentially used to count the score where the score is expected to count until mod 100’s maximum which is 99. This of course is called and integrated into the score counter module which controls when the score exactly increments and begins to count and when it is cleared or starts from 0. All of this is represented by the "text module" which is used to represent any text that is meant to be displayed on the screen such as score, pong and game over this is done using the ascii rom as I previously mentioned. Now that we have discussed how text is represented, it is now time to discuss how the paddle and ball are graphed on the screen and how their locations are adjusted appropriately and in relation to the display size, the speeds of the ball and paddle are also specified to be adjusted if we want to and hit ad hit2 are also changed based on the location of the paddle as well as the miss is also changed, all of that and more is included in the "graphics module".

As for the bonus which is generating sound, we have used a passive buzzer in order to output the sound, but how exactly did we produce the right frequency to output the sound? We have used a frequency generator to generate different frequencies according to the game state; one sound is played once the ball and the paddle collide and the other is played with the gameOver screen. The frequenies used to generate different sound tones are 1000 Hz, 2000 Hz, 440Hz, and 500Hz. Then finally we have used the "sound_top" module in order to instantiate the frequency generator and it also acts as a state machine in  order to run the right state at the right time, for example starting the counter to begin the sound and then starting the right frequency, then breaking the sound and stopping it.

Challenges faced: I would say the main challenges were right at the end of the project and the beginning of the project. At the beginning of the project, we struggled to make the monitor output what we coded on the screen and we could not figure out where the issue was, but we later found out where the problem was and we resolved it. Another challenge was figuring out how to design two scores and to increment by one the appropriate score depending on the appropriate paddle every time the ball collided and how to decrement the number of balls every time either of the players lost. The final challenge was to generate the sound, but it was not too tough to solve as in the end the whole problem was that we were not using the right port to output the sound and also we were trying to make it output sound when the paddle collided with the ball.

Here is a video for a fully functional game https://drive.google.com/file/d/1J1DCXzgKwDArCbET8Yi36CepKKRr3rLX/view?usp=drivesdk
![image](https://github.com/user-attachments/assets/4bb6b5c9-1fd0-4d17-9251-31581ee0fe49)


