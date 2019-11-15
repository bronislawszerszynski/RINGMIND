import ddf.minim.*;
import ddf.minim.signals.*;
import controlP5.*;
import javax.sound.sampled.*;
import ddf.minim.ugens.*;

Minim              minim1;
Minim              minim2;
Minim              minim3;
Minim              minim4;
Minim              minim5;
Minim              minim6;
Minim              minim7;
Minim              minim8;
Minim              minim9;
Minim              minim10;
Minim              minim11;
Minim              minim12;

MultiChannelBuffer sampleBuffer1;
MultiChannelBuffer sampleBuffer2;
MultiChannelBuffer sampleBuffer3;
MultiChannelBuffer sampleBuffer4;

AudioOutput        output1;
AudioOutput        output2;
AudioOutput        output3;
AudioOutput        output4;
AudioOutput        output5;
AudioOutput        output6;
AudioOutput        output7;
AudioOutput        output8;
AudioOutput        output9;
AudioOutput        output10;
AudioOutput        output11;
AudioOutput        output12;

Sampler            sampler;
Sampler            sampler2;
Sampler            sampler3;
Sampler            sampler4;

Mixer.Info[] mixerInfo;

AudioPlayer player1;
AudioPlayer player2;
AudioPlayer player3;
AudioPlayer player4;
AudioPlayer player5;
AudioPlayer player6;
AudioPlayer player7;
AudioPlayer player8;
AudioPlayer player9;
AudioPlayer player10;
AudioPlayer player11;
AudioPlayer player12;

void initAudio(){
 // create Minim and an AudioOutput
  minim1  = new Minim(this);
  minim2  = new Minim(this);
  minim3  = new Minim(this);
  minim4 = new Minim(this);
  minim5  = new Minim(this);
  minim6  = new Minim(this);
  
   mixerInfo = AudioSystem.getMixerInfo();

  for (int i = 0; i < mixerInfo.length; i++)
  {
    println(i + " = " + mixerInfo[i].getName());
  } 

  Mixer mixer = AudioSystem.getMixer(mixerInfo[3]);
  minim1.setOutputMixer(mixer);
  output1 = minim1.getLineOut();
 
  Mixer mixer2 = AudioSystem.getMixer(mixerInfo[7]);
  minim2.setOutputMixer(mixer2);
  output2 = minim2.getLineOut();
 
  sampleBuffer1     = new MultiChannelBuffer( 1, 1024 );
  player1 = minim1.loadFile("1_St.wav"); player1.loop();
 
  sampleBuffer2     = new MultiChannelBuffer( 1, 1024 );
  player2 = minim2.loadFile("2_St.wav"); player2.loop();
    Mixer mixer3 = AudioSystem.getMixer(mixerInfo[3]);
  
  player1.pause();
  player2.pause();
  
  minim3.setOutputMixer(mixer3);
  output3 = minim3.getLineOut();
 
  Mixer mixer4 = AudioSystem.getMixer(mixerInfo[7]);
  minim4.setOutputMixer(mixer4);
  output4 = minim4.getLineOut();
 
  sampleBuffer1     = new MultiChannelBuffer( 1, 1024 );
  player3 = minim3.loadFile("G3_1_St.wav"); player3.loop();
 
  sampleBuffer2     = new MultiChannelBuffer( 1, 1024 );
  player4 = minim4.loadFile("G3_2_St.wav"); player4.loop();

  player3.pause();
  player4.pause();
  
    
    Mixer mixer5 = AudioSystem.getMixer(mixerInfo[3]);
  minim5.setOutputMixer(mixer5);
  output5 = minim5.getLineOut();
 
  Mixer mixer6 = AudioSystem.getMixer(mixerInfo[7]);
  minim6.setOutputMixer(mixer6);
  output6 = minim6.getLineOut();
 
  sampleBuffer1     = new MultiChannelBuffer( 1, 1024 );
  player5 = minim5.loadFile("G4_1_St.wav"); player5.loop();
 
  sampleBuffer2     = new MultiChannelBuffer( 1, 1024 );
  player6 = minim6.loadFile("G4_2_St.wav"); player6.loop();


}
