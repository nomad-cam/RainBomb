import java.util.Calendar;
import java.util.TimeZone;

FileTransferClient ftp = null;

Calendar cal;

PImage img;
PImage background;
PImage legend;
PImage topography;
PImage target;
PImage towns;

String host = "ftp2.bom.gov.au";
String folder = "/anon/gen/radar/";
String username = "anonymous";
String password = "guest";

int frames = 5;
int local = 0;
int count = frames;
String[] loop = new String[frames];

int savedTime = millis();
int varTime;

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
  
  //background(legend);
  //image(background, 0, 0);
  //image(topography, 0, 0);

  cal = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
  
  //pre load initial images
  String tmpIm = newImage();
  
  frameRate(1);
  
  StringList tmp = searchFiles();
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
  
  
  println(images);
  return images;
}

String newImage()
{
  //get the current date & time in UTC...
  
  //int[] datetime = new int[5];
  //datetime[0] = cal.get(Calendar.YEAR);
  int year = cal.get(Calendar.YEAR);
  int month = cal.get(Calendar.MONTH);
  //datetime[1] = (mon + 1);
  month += 1;
  //datetime[2] = cal.get(Calendar.DAY_OF_MONTH);
  int day = cal.get(Calendar.DAY_OF_MONTH);
  //datetime[3] = cal.get(Calendar.HOUR_OF_DAY);
  int hour = cal.get(Calendar.HOUR_OF_DAY);
  int mins = cal.get(Calendar.MINUTE);
  int minute = ((mins / 6) * 6);
  //datetime[4] = min;
  
  //String dateStr = String.format("%4d%02d%02d%02d%02d",datetime[0],datetime[1],datetime[2],datetime[3],datetime[4]);
  String dateStr = String.format("%4d%02d%02d%02d%02d",year,month,day,hour,minute);
  //println(date);
  //String dateStr = join(nf(datetime, 0), "");
  
  String image = "IDR023.T."+dateStr+".png";
  String imgStr = "ftp://"+host+folder+image;
  
  println(image);
  println(imgStr);
  
  local = 0;
  
  try
  {
    ftp = new FileTransferClient();
    //Need to test if iomage is available on server... Might be mismatch between local and server time
    ftp.setRemoteHost(host);
    ftp.setUserName(username);
    ftp.setPassword(password);
    ftp.connect();
    ftp.changeDirectory(folder);
    
    String[] files = ftp.directoryNameList();
    println(files);
    
    if (ftp.exists(image))
    {
      println("Downloading... "+image+" :"+imgStr);
      ftp.downloadURLFile(local+".png", imgStr);
      //ftp.downloadURLFile("IDR023.T.201310290954.png", "ftp://ftp2.bom.gov.au/anon/gen/radar/IDR023.T.201310290954.png");
    }
    else
    {
      minute -= 6;
      if (minute < 0)
      {
        minute = 54;
        hour -= 1;
      }
      dateStr = String.format("%4d%02d%02d%02d%02d",year,month,day,hour,minute);
      image = "IDR023.T."+dateStr+".png";
      imgStr = "ftp://"+host+folder+image;
      //println("New: "+dateStr);
      if (ftp.exists(image))
      {
        println("Downloading... "+image+" :"+imgStr);
        ftp.downloadURLFile(local+".png", imgStr);
        //ftp.downloadURLFile("IDR023.T.201310290954.png", "ftp://ftp2.bom.gov.au/anon/gen/radar/IDR023.T.201310290954.png");
      }
      else
      {
        //image = searchFiles(ftp, year, month, day, hour, minute);
      }
    }
    
    for (int i=1; i<=frames; i++)
    {
      minute -= 6;
      if (minute < 0)
      {
        minute = 54;
        hour -= 1;
      }
      dateStr = String.format("%4d%02d%02d%02d%02d",year,month,day,hour,minute);
      image = "IDR023.T."+dateStr+".png";
      imgStr = "ftp://"+host+folder+image;
      println(i+"New: "+imgStr);
      ftp.downloadURLFile(i+".png", imgStr);
    }
    println("Loop collect complete");
    
    ftp.disconnect();
  }
  catch (Exception e)
  {
    e.printStackTrace();
  }
  
  return image;
}

void draw()
{  
  //noLoop();
  //println(count);
  varTime = millis() - savedTime;
  
  //Timer to check server every minute
  if ((varTime / 60000) > 1.0)
  {
    String image = newImage();
    img = loadImage(image, "png");
    
    //update the saved time
    savedTime = millis();
  }
  
  
  //String image = newImage();
  //img = loadImage(image, "png");
    
  //Image format IDR023.T.201310280942.png
  drawBackground();
  image(loadImage(count+".png", "png"),0,0);
  //delay(200);
  
  count = count - 1;
  if (count < 0)
  {
    count = frames;
  }
  
 
  //Overlay other images...
  image(target, 0, 0);
  image(towns, 0, 0);
  
}
