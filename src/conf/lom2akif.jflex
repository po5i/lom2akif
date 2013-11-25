package gr.agroknow.metadata.transformer.lom2akif;

import java.text.SimpleDateFormat;
import java.util.Calendar;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

import net.zettadata.generator.tools.LOMlreLRT;
import net.zettadata.generator.tools.Toolbox;
import net.zettadata.generator.tools.ToolboxException;

%%
%class LOM2AKIF
%standalone
%unicode

%{
    private JSONObject akif ;
    private JSONObject jObject ;
    private JSONObject jObject2 ;
    private JSONArray jArray ;
    private StringBuilder tmp ;   
    private String language ;
    private String source ;
    private String potentialLangs ;
    private JSONObject expression ;
    private JSONObject manifestation ;
    private JSONObject item ;
    private JSONArray contributors ;
    private LOMlreLRT lrt = new LOMlreLRT() ;

    public String toString() 
    {
      return akif.toJSONString() ;
    }
    
	public JSONObject getAkif() {
		return akif;
	}

        @SuppressWarnings("unchecked")
	public void setPotentialLangs(String langs)
	{
		potentialLangs = langs;
	}

	@SuppressWarnings("unchecked")
	public void setSet(String set) {
		akif.put("set", set) ;
	}
	
	@SuppressWarnings("unchecked")
	public void setId(int id)
	{
		akif.put("identifier", new Integer( id ) ) ;
	}
	
	@SuppressWarnings("unchecked")
	public void init()
	{
		akif = new JSONObject() ;
		akif.put( "status", "published" ) ;
		akif.put( "generateThumbnail", new Boolean( true ) ) ;
		akif.put( "creationDate", utcNow() ) ;
		akif.put( "lastUpdateDate", utcNow() ) ;
		akif.put( "languageBlocks", new JSONObject() ) ;
		akif.put( "tokenBlock", new JSONObject() ) ;
		akif.put( "expressions", new JSONArray() ) ;
		akif.put( "rights", new JSONObject() ) ;
		akif.put( "contributors", new JSONArray() ) ;
		akif.put( "learningObjectives", new JSONObject() ) ;
	}
	
	private String utcNow() 
	{
		Calendar cal = Calendar.getInstance();
		SimpleDateFormat sdf = new SimpleDateFormat( "yyyy-MM-dd" );
		return sdf.format(cal.getTime());
	}
	
	private String extract( String element )
	{	
		return element.substring(element.indexOf(">") + 1 , element.indexOf("</") );
	}
	
%}

%state LOM
%state GENERAL
%state TITLE
%state TITLELANGUAGE
%state TITLESTRING
%state DESCRIPTION
%state DESCRIPTIONLANGUAGE
%state DESCRIPTIONSTRING
%state COVERAGE
%state COVERAGELANGUAGE
%state COVERAGESTRING
%state KEYWORD
%state KEYWORDLANGUAGE
%state KEYWORDSTRING
%state TECHNICAL
%state EDUCATIONAL
%state LEARNINGRESOURCETYPE
%state ENDUSERROLE
%state CONTEXT
%state TYPICALAGERANGE
%state CLASSIFICATION
%state TAXONPATH
%state TAXON
%state RIGHTS
%state RDESCRIPTION
%state RDESCRIPTIONLANGUAGE
%state RDESCRIPTIONSTRING
%state LIFECYCLE
%state CONTRIBUTE
%state ROLE
%state ENTITY
%state RELATION
%state LEARNINGOBJECTIVE

%%

<YYINITIAL>
{	
	"<lom"
	{
		tmp = new StringBuilder() ;
		yybegin( LOM ) ;
	}
}

<LOM>
{
	"</lom>"
	{
		yybegin( YYINITIAL ) ;
	}

	"<general/>" {}
	
	"<general />" {}

	"<general"
	{
		jObject = new JSONObject() ;
		jArray = new JSONArray() ;
		yybegin( GENERAL ) ;
	}
	
	"<educational />" {}
	
	"<educational/>" {}
	
	"<educational"
	{
		yybegin( EDUCATIONAL ) ;
		jObject = (JSONObject)akif.get( "tokenBlock" ) ;
	}
	
	"<technical/>" {}
	
	"<technical />" {}
	
	"<technical"
	{
		manifestation = new JSONObject() ;
		// temporary solution everything is an experience
		manifestation.put( "name", "experience" ) ; 
		yybegin( TECHNICAL ) ;
	}
		
	"<classification/>" {}
		
	"<classification />" {}
		
	"<classification"
	{
		yybegin( CLASSIFICATION ) ;
		jObject = (JSONObject)akif.get( "tokenBlock" ) ;
	}

	"<rights />" {}

	"<rights/>" {}
	
	"<rights"
	{
		yybegin( RIGHTS ) ;
		jObject = (JSONObject)akif.get( "rights" ) ;
	}

	"<lifeCycle/>" {}
	
	"<lifeCycle />" {}
	
	"<lifeCycle"
	{
		yybegin( LIFECYCLE ) ;
		jArray = (JSONArray)akif.get( "contributors" ) ;
	}
	
	"<relation/>" {}
	
	"<relation />" {}
	
	"<relation" 
	{
		yybegin( RELATION ) ;
		jObject = (JSONObject)akif.get( "learningObjectives" ) ;
	}
	
}

<RELATION>
{

	"</relation>"
	{
		akif.put( "learningObjectives", jObject ) ;
		yybegin( LOM ) ;
	}

	"<catalog>Agricom competences</catalog>"
	{
		if ( jObject.containsKey( "Agricom competences" ) )
		{
			jArray = (JSONArray)jObject.get( "Agricom competences" ) ;
		}
		else
		{
			jArray = new JSONArray() ;
		}
		yybegin( LEARNINGOBJECTIVE ) ;
	}

}

<LEARNINGOBJECTIVE>
{
	"<entry>".+"</entry>"
	{
		jArray.add( extract( yytext() ).trim() ) ;
		jObject.put( "Agricom competences", jArray ) ;
		yybegin( RELATION ) ;
	}
}

<LIFECYCLE>
{
	"</lifeCycle>"
	{
		akif.put( "contributors", jArray ) ;
		yybegin( LOM ) ;		
	}
	
	"<contribute />" {}
	
	"<contribute/>" {}
	
	"<contribute"
	{
		jObject = new JSONObject() ;
		yybegin( CONTRIBUTE ) ;
	}
	
}

<CONTRIBUTE>
{
	"</contribute>"
	{
		jArray.add( jObject ) ;
		yybegin( LIFECYCLE ) ;
	}
	
	"<role />" {}

	"<role/>" {}
	
	"<role"
	{
		yybegin( ROLE) ;
	}
	
	"<dateTime".+"</dateTime>"
	{
		jObject.put( "date", extract( yytext() ).trim() ) ;
	}
	
	"<entity/>" {}
	
	"<entity />" {}
	
	"<entity"
	{
		yybegin( ENTITY ) ;
	}
}

<ENTITY>
{
	"</entity>"
	{
		yybegin( CONTRIBUTE ) ;
	}
	
	"\nN:".+
	{
		jObject.put( "name", yytext().substring(3) ) ;
	}
	
	"\nORG:".+
	{
		jObject.put( "organization", yytext().substring(5) ) ;
	}
}

<ROLE>
{
	"</role>"
	{
		yybegin( CONTRIBUTE ) ;
	}
	
	"<value".+"</value>"
	{
		jObject.put( "role", extract( yytext() ).trim() ) ;
	}
}

<RIGHTS>
{
	"</rights>"
	{
		akif.put( "rights", jObject ) ;
		yybegin( LOM ) ;		
	}
	
	"<description />" {}
	
	"<description/>" {}
	
	"<description"
	{
		yybegin( RDESCRIPTION ) ;
		language = null ;
	}
}

<RDESCRIPTION>
{
	"<string language=\""
	{
		yybegin( RDESCRIPTIONLANGUAGE ) ;
	}
	
	"<string>"
	{
		// if language is missing, use English as default
		language = "en" ;               
		yybegin( RDESCRIPTIONSTRING ) ;
	}
	
	"</description>"
	{
		yybegin( RIGHTS ) ;
	}
}

<RDESCRIPTIONLANGUAGE>
{
	"\">"|"\" >"
	{
		try
		{
			language = Toolbox.getInstance().toISO6391( tmp.toString().trim() ) ;
		}
		catch( ToolboxException te )
		{
			System.err.println( te.getMessage() ) ;
		}
		tmp = new StringBuilder() ;
		yybegin( RDESCRIPTIONSTRING ) ;
	}
	
	.
	{
		tmp.append( yytext() ) ;
	}
}

<RDESCRIPTIONSTRING>
{
	"</string>"
	{
		if ( tmp.toString().trim().startsWith( "http://" ) )
		{
			jObject.put( "url", tmp.toString().trim() ) ;
		}
		else
		{
			if ( jObject.containsKey( "description" ) )
			{
				((JSONObject)jObject.get( "description" )).put( language, tmp.toString().trim() ) ;
			}
			else
			{
				jObject2 = new JSONObject() ;
				jObject2.put( language, tmp.toString().trim() ) ; 
				jObject.put( "description", jObject2 ) ;
			}
		}
		tmp = new StringBuilder() ;
		yybegin( RDESCRIPTION ) ;	
	}
			
	.
	{
		tmp.append( yytext() ) ;
	}
}



<CLASSIFICATION>
{
	"</classification>"
	{
		akif.put( "tokenBlock", jObject ) ;
		yybegin( LOM ) ;		
	}
	
	"<taxonPath"
	{
		yybegin( TAXONPATH ) ;
		// set a default value for the taxon path source
		source = "thesaurus" ;
	}
	
	"<taxonPath/>" {}
	
	"<taxonPath />" {}
	
}

<TAXONPATH>
{

	"</taxonPath>"
	{
		jObject.put( "taxonPaths", jObject2 ) ;
		yybegin( CLASSIFICATION ) ;		
	}

	"<string language=\"".+"\">".+"</string>"
	{
		source = extract( yytext() ).trim() ; 
		if ( jObject.containsKey( "taxonPaths" ) )
		{
			jObject2 = (JSONObject)jObject.get( "taxonPaths" ) ;
		}
		else
		{
			jObject2 = new JSONObject() ;
		}
	}

	"<taxon"
	{
		if ( jObject2.containsKey( source ) )
		{
			jArray = (JSONArray)jObject2.get( source ) ;
		}
		else
		{
			jArray = new JSONArray() ;
		}
		yybegin( TAXON ) ;
	}

}

<TAXON>
{
	"</taxon>"
	{
		jObject2.put( source, jArray ) ;
		yybegin( TAXONPATH ) ;		
	}
	
	"<id".+"</id>"
	{
		jArray.add( extract( yytext() ).trim() ) ;
	}
}

<EDUCATIONAL>
{
	"</educational>"
	{
		akif.put( "tokenBlock", jObject ) ;
		yybegin( LOM ) ;		
	}
	
	"<learningResourceType/>" {}
	
	"<learningResourceType />" {}
	
	"<learningResourceType"
	{
		if ( jObject.containsKey( "learningResourceTypes" ) )
		{
			jArray = (JSONArray)jObject.get( "learningResourceTypes" ) ;
		}
		else
		{
			jArray = new JSONArray() ;
		}
		yybegin( LEARNINGRESOURCETYPE ) ;
	}
	
	"<intendedEndUserRole/>" {}
	
	"<intendedEndUserRole />" {}
	
	"<intendedEndUserRole"
	{
		if ( jObject.containsKey( "endUserRoles" ) )
		{
			jArray = (JSONArray)jObject.get( "endUserRoles" ) ;
		}
		else
		{
			jArray = new JSONArray() ;
		}
		yybegin( ENDUSERROLE ) ;
	}
	
	"<context/>" {}
	
	"<context />" {}
	
	"<context"
	{
		if ( jObject.containsKey( "contexts" ) )
		{
			jArray = (JSONArray)jObject.get( "contexts" ) ;
		}
		else
		{
			jArray = new JSONArray() ;
		}
		yybegin( CONTEXT ) ;
	}
	
	"<typicalAgeRange />" {}
	
	"<typicalAgeRange/>" {}
	
	"<typicalAgeRange"
	{
		yybegin( TYPICALAGERANGE ) ;				
	}
	
}

<TYPICALAGERANGE>
{
	"</typicalAgeRange>"
	{
		yybegin( EDUCATIONAL ) ;		
	}
	
	"<string".+"</string>"
	{
		jObject.put( "ageRange", extract( yytext() ).trim() ) ;
	}
}


<CONTEXT>
{
	"</context>"
	{
		jObject.put( "contexts", jArray ) ;
		yybegin( EDUCATIONAL ) ;		
	}
	
	"<value".+"</value>"
	{
		jArray.add( extract( yytext() ).trim().toLowerCase() ) ;
	}
}

<ENDUSERROLE>
{
	"</intendedEndUserRole>"
	{
		jObject.put( "endUserRoles", jArray ) ;
		yybegin( EDUCATIONAL ) ;		
	}
	
	"<value".+"</value>"
	{
		jArray.add( extract( yytext() ).trim() ) ;
	}
}

<LEARNINGRESOURCETYPE>
{
	"</learningResourceType>"
	{
		jArray.addAll( lrt.getLearningResourceTypes() ) ;
		jObject.put( "learningResourceTypes", jArray ) ;
		yybegin( EDUCATIONAL ) ;		
	}
	
	"<value".+"</value>"
	{
		try 
		{
			lrt.submitLOMResourceType( extract( yytext() ).trim() ) ;
		}
		catch (ToolboxException e1) 
		{
			// ignore silently. 	
		}
		
	}
}



<TECHNICAL>
{
	"</technical>"
	{
		if ( expression == null )
		{
			// set a default expression (here English)
			expression = new JSONObject() ;
			expression.put( "language", "en" ) ;
		}
		if ( expression.containsKey( "manifestations" ) )
		{
			((JSONArray)expression.get( "manifestations" )).add( manifestation ) ;
		}
		else
		{
			jArray = new JSONArray() ;
			jArray.add( manifestation ) ;
			expression.put( "manifestations", jArray ) ;
			jArray = new JSONArray() ;
			jArray.add( expression ) ;
			akif.put( "expressions", jArray ) ;
		}
		yybegin( LOM ) ;
	}
	
	"<format".+"</format>"
	{
		manifestation.put( "parameter", extract( yytext() ).trim() ) ; 
	}
	
	"<location".+"</location>"
	{
		item = new JSONObject() ;
		item.put( "broken", new Boolean( false ) ) ;
		item.put( "url", extract(  yytext() ).trim().replaceAll("&amp;", "&" ) ) ;
		if ( manifestation.containsKey( "items" ) )
		{
			((JSONArray)manifestation.get( "items" )).add( item ) ;
		}
		else
		{
			jArray = new JSONArray() ;
			jArray.add( item ) ;
			manifestation.put( "items", jArray ) ;
		}
	}
	
}

<GENERAL>
{
	"</general>"
	{
		yybegin( LOM ) ;
	}
	
	"<title />" {}
	
	"<title/>" {}
	
	"<title"
	{
		language = null ;
		yybegin( TITLE ) ;
	}
	
	"<description />" {}
	
	"<description/>" {}
	
	"<description"
	{
		language = null ;
		yybegin( DESCRIPTION ) ;	
	}
	
	"<coverage />" {}
	
	"<coverage/>" {}
	
	"<coverage"
	{
		language = null ;
		yybegin( COVERAGE ) ;	
	}
	
	"<keyword />" {}
	
	"<keyword/>" {}
	
	"<keyword"
	{
		language = null ;
		yybegin( KEYWORD ) ;
	}
	
	"<language".+"</language>"
	{
		language = extract( yytext().trim() ) ;
		try
		{
			language = Toolbox.getInstance().toISO6391( language ) ;
		}
		catch( ToolboxException te )
		{
			System.err.println( te.getMessage() ) ;
		}
		expression = new JSONObject() ;
		expression.put( "language", language ) ;
	}
}

<KEYWORD>
{
	"<string language=\""
	{
		yybegin( KEYWORDLANGUAGE ) ;
	}

	"<string>"
	{
		// if lang string is missing, use the result of lang detection
		tmp = new StringBuilder() ;                            
		yybegin( KEYWORDSTRING ) ;        
	}
	
	"</keyword>"
	{
		yybegin( GENERAL ) ;
	}
}

<KEYWORDLANGUAGE>
{
	"\">"|"\" >"
	{
		try
		{
			language = Toolbox.getInstance().toISO6391( tmp.toString().trim() ) ;
		}
		catch( ToolboxException te )
		{
			System.err.println( te.getMessage() ) ;
		}
		tmp = new StringBuilder() ;
		yybegin( KEYWORDSTRING ) ;
	}
	
	.
	{
		tmp.append( yytext() ) ;
	}
}

<KEYWORDSTRING>
{
	"</string>"
	{       
                
                 if (language == null){
                    try
                    {
                            language = Toolbox.getInstance().detectLanguage( tmp.toString().trim(), "en, fr, el" ) ;
                    }
                    catch( ToolboxException te )
                    {
                            System.out.println( te.getMessage() ) ;
                    }
                }

		if ( ((JSONObject)akif.get( "languageBlocks" )).containsKey( language ) )
		{
			if (((JSONObject)((JSONObject)akif.get( "languageBlocks" )).get( language )).containsKey( "keywords" ) )
			{
				((JSONArray)((JSONObject)((JSONObject)akif.get( "languageBlocks" )).get( language )).get( "keywords" )).add( tmp.toString().trim() ) ;
			}
			else
			{
				jArray = new JSONArray() ;
				jArray.add( tmp.toString().trim() ) ;
				((JSONObject)((JSONObject)akif.get( "languageBlocks" )).get( language )).put("keywords", jArray ) ;
			}
		}
		else
		{
			jArray = new JSONArray() ;
			jArray.add( tmp.toString().trim() ) ;
			jObject = new JSONObject() ;
			jObject.put("keywords", jArray ) ;
			((JSONObject)akif.get( "languageBlocks" )).put( language, jObject ) ;
		}
		tmp = new StringBuilder() ;
		yybegin( KEYWORD ) ;	
	}
			
	.
	{
		tmp.append( yytext() ) ;
	}
}

<COVERAGE>
{
	"<string language=\""
	{
		yybegin( COVERAGELANGUAGE ) ;
	}
	
	"<string>"
	{
		// if language is missing, use English as default
		language = "en" ;
		yybegin( COVERAGESTRING ) ;
	}
	
	"</coverage>"
	{
		yybegin( GENERAL ) ;
	}
}

<COVERAGELANGUAGE>
{
	"\">"|"\" >"
	{
		try
		{
			language = Toolbox.getInstance().toISO6391( tmp.toString().trim() ) ;
		}
		catch( ToolboxException te )
		{
			System.err.println( te.getMessage() ) ;
		}
		tmp = new StringBuilder() ;
		yybegin( COVERAGESTRING ) ;
	}
	
	.
	{
		tmp.append( yytext() ) ;
	}
}

<COVERAGESTRING>
{
	"</string>"
	{
		if ( ((JSONObject)akif.get( "languageBlocks" )).containsKey( language ) )
		{
			((JSONObject)((JSONObject)akif.get( "languageBlocks" )).get( language )).put("coverage", tmp.toString()) ;
		}
		else
		{
			jObject = new JSONObject() ;
			jObject.put( "coverage", tmp.toString() ) ; 
			((JSONObject)akif.get( "languageBlocks" )).put( language, jObject ) ;
		}
		tmp = new StringBuilder() ;
		yybegin( COVERAGE ) ;	
	}
			
	.
	{
		tmp.append( yytext() ) ;
	}
}

<DESCRIPTION>
{
	"<string language=\""
	{
		yybegin( DESCRIPTIONLANGUAGE ) ;
	}

	"<string>"
	{
		// if lang string is missing, use the result of lang detection
		tmp = new StringBuilder() ;                            
		yybegin( DESCRIPTIONSTRING ) ;
        
	}
       	
	"</description>"
	{
		yybegin( GENERAL ) ;
	}
}

<DESCRIPTIONLANGUAGE>
{
	"\">"|"\" >"
	{
		try
		{
			language = Toolbox.getInstance().toISO6391( tmp.toString().trim() ) ;
		}
		catch( ToolboxException te )
		{
			System.err.println( te.getMessage() ) ;
		}
		tmp = new StringBuilder() ;
		yybegin( DESCRIPTIONSTRING ) ;
	}
	
	.
	{
		tmp.append( yytext() ) ;
	}
}

<DESCRIPTIONSTRING>
{
	"</string>"
	{       
               if (language == null){
                    try
                    {
                            language = Toolbox.getInstance().detectLanguage( tmp.toString().trim() ) ;
                    }
                    catch( ToolboxException te )
                    {
                            System.err.println( te.getMessage() ) ;
                    }
                }

                
		if ( ((JSONObject)akif.get( "languageBlocks" )).containsKey( language ) )
		{
			((JSONObject)((JSONObject)akif.get( "languageBlocks" )).get( language )).put("description", tmp.toString()) ;
		}
		else
		{                                         
			jObject = new JSONObject() ;
			jObject.put( "description", tmp.toString() ) ;
			((JSONObject)akif.get( "languageBlocks" )).put( language, jObject ) ;
		}
		tmp = new StringBuilder() ;
		yybegin( DESCRIPTION ) ;	
	}
		
	.
	{
		tmp.append( yytext() ) ;
	}
}

<TITLE>
{
	"<string language=\""
	{
		tmp = new StringBuilder() ;
		yybegin( TITLELANGUAGE ) ;
	}
	
	"<string>"
        {
                // if lang string is missing, use the result of lang detection
                tmp = new StringBuilder() ;
                yybegin( TITLESTRING ) ;
        
        }
	
	"</title>"
	{
		yybegin( GENERAL ) ;
	}
}

<TITLELANGUAGE>
{
	"\">"|"\" >"
	{
		try
		{
			language = Toolbox.getInstance().toISO6391( tmp.toString().trim() ) ;
		}
		catch( ToolboxException te )
		{
			System.err.println( te.getMessage() ) ;
		}
		tmp = new StringBuilder() ;
		yybegin( TITLESTRING ) ;
	}
	
	.
	{
		tmp.append( yytext() ) ;
	}
}

<TITLESTRING>
{
	"</string>"
	{       
                 if (language == null){
                    try
                    {
                            language = Toolbox.getInstance().detectLanguage( tmp.toString().trim() ) ;
                    }
                    catch( ToolboxException te )
                    {
                            System.err.println( te.getMessage() ) ;
                    }
                }
        
		if ( ((JSONObject)akif.get( "languageBlocks" )).containsKey( language ) )
		{
			((JSONObject)((JSONObject)akif.get( "languageBlocks" )).get( language )).put("title", tmp.toString()) ;
		}
		else
		{
			jObject = new JSONObject() ;
			jObject.put( "title", tmp.toString() ) ;
			((JSONObject)akif.get( "languageBlocks" )).put( language, jObject ) ;
		}
		tmp = new StringBuilder() ;
		yybegin( TITLE ) ;	
	}
	
	.
	{
		tmp.append( yytext() ) ;
	}
}

/* error fallback */
.|\n 
{
	//throw new Error("Illegal character <"+ yytext()+">") ;
}