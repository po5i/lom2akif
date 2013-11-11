package gr.agroknow.metadata.transformer.lom2akif;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;

import org.apache.commons.io.FileUtils;


public class Main 
{
	// public static final String SET = "RUFORUM" ;
	
	// public static final String INPUT_FOLDER = "/Users/dmssrt/tmp/transformer/LOM/" + SET ;
	// public static final String OUTPUT_FOLDER = "/Users/dmssrt/tmp/transformer/AKIF/" + SET  ;
	
	public static void main(String[] args) throws IOException
	{
		if ( args.length != 4 )
		{
			System.err.println( "Usage : java -jar lom2akif.jar <INPUT_FOLDER> <OUTPUT_FOLDER> <BAD_FOLDER> <SET_NAME>" ) ;
			System.exit( -1 ) ;
		}
		String inputFolder = args[0] ;
		String outputFolder = args[1] ;
		String badFolder = args[2] ;
		String set = args[3] ;
                String potentialLangs = "en,fr,el,de";
				
		LOM2AKIF transformer = null ;
		int identifier = 0 ;
		// File inputDirectory = new File( inputFolder + File.separator + set ) ;
		File inputDirectory = new File( inputFolder ) ;
		FileReader fr = null ;
		int wrong = 0 ;
		for (String lom: inputDirectory.list() )
		{
			try
			{
				identifier = Integer.parseInt( lom.substring(0, lom.length()-4 ) ) ;
				// fr = new FileReader( inputFolder + File.separator + set + File.separator + lom ) ;
				fr = new FileReader( inputFolder + File.separator + lom ) ;
				transformer = new LOM2AKIF( fr ) ;
				transformer.init() ;
				transformer.setId( identifier ) ;
				transformer.setSet( set ) ;
                                transformer.setPotentialLangs (potentialLangs);
                                
				transformer.yylex() ;
				FileUtils.writeStringToFile( new File( outputFolder + File.separator +identifier + ".json" ) , transformer.toString() ) ;
			}
			catch( NumberFormatException nfe )
			{
				wrong++ ;
				FileUtils.copyFile( new File(inputFolder + File.separator + lom) , new File( badFolder + File.separator + lom ) )  ;
				System.out.println( "Wrong file : " + lom ) ;
				// nfe.printStackTrace() ;
				// System.exit( identifier ) ;
			}
			catch( Exception e )
			{
				wrong++ ;
				FileUtils.copyFile( new File(inputFolder + File.separator + lom) , new File( badFolder + File.separator + lom ) )  ;
				System.out.println( "Wrong file : " + identifier ) ;
				//e.printStackTrace() ;
				//System.exit( identifier ) ;
			}
			finally
			{
				try 
				{
					if ( fr != null )
					{
						fr.close() ;
					}
				} 
				catch( IOException ioe ) 
				{
					//ioe.printStackTrace() ;
				}
			}
		}
		System.out.println( "#wrong : " + wrong ) ;
	}

}