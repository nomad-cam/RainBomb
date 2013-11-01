import java.util.prefs.*;

FileTransferClient ftp = null;
FileTransferClient ftpD = null;

Preferences uPrefs = Preferences.userRoot();

PImage img;
PImage background;
PImage legend;
PImage topography;
PImage target;
PImage towns;
PImage loading;

String host = "ftp2.bom.gov.au";
String folder = "/anon/gen/radar/";
String username = "anonymous";
String password = "guest";

int frames = 5;
int local = 0;
int count = frames;
String[] loop = new String[frames];
StringList image = new StringList();

int savedTime = millis();
int varTime;

boolean runonce = true;

void drawBackground()
{
  legend = loadImage("http://www.bom.gov.au/products/radar_transparencies/IDR.legend.0.png", "png");
  topography = loadImage("http://www.bom.gov.au/products/radar_transparencies/IDR023.topography.png", "png");
  background = loadImage("http://www.bom.gov.au/products/radar_transparencies/IDR023.background.png", "png");
    
  background(legend);
  image(background, 0, 0);
  image(topography, 0, 0);
  
}

void setup()
{
  size(512, 557);
  drawBackground();
  //legend = loadImage("http://www.bom.gov.au/products/radar_transparencies/IDR.legend.0.png", "png");
  //background = "http://www.bom.gov.au/products/radar_transparencies/IDR023.background.png";
  //topography = loadImage("http://www.bom.gov.au/products/radar_transparencies/IDR023.topography.png", "png");
  //background = loadImage("http://www.bom.gov.au/products/radar_transparencies/IDR023.background.png", "png");
  target = loadImage("http://www.bom.gov.au/products/radar_transparencies/IDR023.range.png", "png");
  towns = loadImage("http://www.bom.gov.au/products/radar_transparencies/IDR023.locations.png", "png");
  loading = loadImage("http://www.bom.gov.au/scripts/radar/IDR.please.wait.gif", "gif");
  
  image(loading,0,0);

  frameRate(1.0);
  
  //StringList tmp = searchFiles();
}

StringList searchFiles()
{
  println("Searching for files...");
  StringList images = new StringList();
  
  try
  {
    ftp = new FileTransferClient();
    
    ftp.setRemoteHost(host);
    ftp.setUserName(username);
    ftp.setPassword(password);
    ftp.connect();
    ftp.changeDirectory(folder);
    
    //Don't rely on local timestamps... get directory list and search for files
    String[] files = ftp.directoryNameList();

    ftp.disconnect();
    
    int i = 0;
    
    for(int j = 0; j < files.length; j++)
    {
      if (files[j].startsWith("IDR023.T."))
      {
        println("Found File: "+files[j]);
        images.append(files[j]);
      }
    }
    
  }
  catch (Exception e)
  {
    e.printStackTrace();
  }
  
  return images;
}

StringList newImage()
{
  String image = new String(); // = "IDR023.T."+dateStr+".png";
  String imgStr = new String(); // = "ftp://"+host+folder+image;
  StringList Images = new StringList();
  //println(image);
  //println(imgStr);
  
  local = 0;
  
  try
  {
    ftpD = new FileTransferClient();
    //Need to test if iomage is available on server... Might be mismatch between local and server time
    ftpD.setRemoteHost(host);
    ftpD.setUserName(username);
    ftpD.setPassword(password);
    ftpD.connect();
    ftpD.changeDirectory(folder);
    
    Images = searchFiles();
    
    for (int i=0; i<Images.size(); i++)
    {
      
      image = Images.get(i);
      imgStr = "ftp://"+host+folder+image;
      //println(i+"New: "+imgStr);
      ftpD.downloadURLFile(i+".png", imgStr);
    }
    //println("Loop collect complete");
    
    ftpD.disconnect();
  }
  catch (Exception e)
  {
    e.printStackTrace();
  }
  
  return Images;
}

void draw()
{  
  //noLoop();
  //println(count);
  
  if (runonce)
  {
    //println("Run once...");
    image(loading, 0, 0);
    image = newImage();
    runonce = false;
  }
  
  varTime = millis() - savedTime;
  
  //Timer to check server every 3 minutes
  if ((varTime / 180000) > 1.0)
  {
    image(loading, 0, 0);
    image = newImage();
    //img = loadImage(image, "png");
    
    //update the saved time
    savedTime = millis();
  }
  
  
  //String image = newImage();
  //img = loadImage(image, "png");
    
  //Image format IDR023.T.201310280942.png
  drawBackground();
  image(loadImage(count+".png", "png"),0,0);
  //delay(200);
  
  count = count + 1;
  if (count >= image.size())
  {
    count = 0;
  }
  
 
  //Overlay other images...
  image(target, 0, 0);
  image(towns, 0, 0);
  
}
