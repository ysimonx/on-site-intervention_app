<?php
    // Find a randomDate between $start_date and $end_date
    function randomDate($start_date, $end_date)
    {
        // Convert to timetamps
        $min = strtotime($start_date);
        $max = strtotime($end_date);

        // Generate random number using above bounds
        $val = rand($min, $max);

        // Convert back to desired date format
        return date('d/m/Y H:i:s', $val);
    }

    $tab_field=[
    "Vue d'ensemble unité intérieure",
    "Fixation unité intérieure",
    "Plaque signalétique unité intérieure",
    "Calorifuge circuit frigorigene",
    "Vanne d'équilibrage",
    "Vue d'ensemble unité extérieure",
    "Circulation d'air",
    "Plaque signalétique unité extérieure",
    "Fixation unité extérieure",
    "Radiateur",
    "Façade de la maison",
    "Ajout de photos"
    ];

    $tab_pro=[
        "Entrepose",
        "BCI",
        "Plombier arnold"
    ];

    $tab_beneficiaire=[
        "Jean-Laurent Schaub",
        "Franck Annamayer",
        "Cyril Laroque"
    ]
?>
<html>
    <head>
    <style>

        *,
        *::before,
        *::after {
        box-sizing: border-box;
        }

        body {
            font-family: "Figtree", sans-serif;
            font-size: 0.9rem;
            line-height: 1.2rem;
        }
        figure {
            margin: 0;
            padding: 0;

            width: 300px;
            height: 300px;
        }

        .articles {
            display: flex;
            flex-direction: row;
            flex-wrap: wrap;
            # max-width: 1200px;
            margin-inline: auto;
            padding-inline: 24px;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 24px;
        }

        .article-wrapper {
            display: flex;
            flex-direction: row;
            background-color: #CCC;
        }
        article {
            width: 800px;
            height: 300px;
            --img-scale: 1.001;
            --title-color: black;
            --link-icon-translate: -20px;
            --link-icon-opacity: 0;
            position: relative;
            border-radius: 16px;
            box-shadow: none;
            background: #fff;
            transform-origin: center;
            transition: all 0.4s ease-in-out;
            overflow: hidden;
        }


/* basic article elements styling */
article h2 {
  margin: 0 0 3px 0;
  font-size: 1.1rem;
  letter-spacing: 0.04em;
  color: var(--title-color);
  transition: color 0.3s ease-out;
}
article h3 {
  margin: 0 0 2px 0;
  font-size: 1.0rem;
  letter-spacing: 0.02em;
  color: var(--title-color);
  transition: color 0.3s ease-out;
}

.article-body {
  padding: 10px;
}


article a::after {
  position: absolute;
  inset-block: 0;
  inset-inline: 0;
  cursor: pointer;
}

article a .icon {
  min-width: 24px;
  width: 24px;
  height: 24px;
  margin-left: 5px;
  transform: translateX(var(--link-icon-translate));
  opacity: var(--link-icon-opacity);
  transition: all 0.3s;
}

img {
    width: inherit;
    height: inherit;
    object-fit: cover;
}


.sr-only:not(:focus):not(:active) {
  clip: rect(0 0 0 0); 
  clip-path: inset(50%);
  height: 1px;
  overflow: hidden;
  position: absolute;
  white-space: nowrap; 
  width: 1px;
}
    </style>

    </head>
    <body>
        <div id="main">
	    <div id="timeline">
                <h1>Photos - Reviews - Timeline</h1>    
                <section class="articles">

                <?php
                    echo("\n");
                    for($i=0; $i< 20; $i++) {

                        $rand_keys = array_rand($tab_field, 1);
                        $rand_keys_beneficiaire = array_rand($tab_beneficiaire, 1);
                        $rand_keys_pro = array_rand($tab_pro, 1);
                       
                        $int= rand(1262055681,1262055681);
			$random_date = date("d/m/Y H:i:s",$int);

			$int_image=rand(2,7);
			$image_url="0000".$int_image."Fichier.png";
                       
                ?>
                    <article>  
                        <div class="article-wrapper">  
                            <figure>
			    <img src="<?php echo($image_url); ?>" />
                            </figure>
                            <div class="article-body">
                                <div><?php echo($random_date ); ?></div>
                                <h2><?php echo($tab_field[$rand_keys]); ?></h2>
                                <h3><?php echo($tab_pro[$rand_keys_pro]); ?>/<?php echo($tab_beneficiaire[$rand_keys_beneficiaire]); ?></h3>

                                <h3><a href="geste.html">Installation Pompe à chaleur</a></h3>
                                <p><b>Commentaire</b>:<i>bla bla bla </i></p>
                                <p>
                                ref cadastrale : BX451 / Longitude: 43.4452019 / Latitude: 5.6311607<br />
                                    Attendu photo : Numero de plaque signaletique<br />
                                    Attendu bénéficiaire : Carte identité
                                    <br />
                                </p>
                               <select><option>à valider</option><option>à refaire</option><option>accepté</option></select>
                                
                            </div>
                        </div>
                    </article>
                   
                <?php
                    }
                ?>
                 </articles>
                </section>
            </div>
        </div>
    </body>
</html>
