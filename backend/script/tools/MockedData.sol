// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "../../src/BlockFunding.sol";
import "../../src/BlockFundingProject.sol";

library MockedData {
    address public constant targetWallet = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    // For project in funding phase
    uint32 public constant inFundingPhaseCampaignStartingDateTimestamp = 1708220568;
    uint32 public constant inFundingPhaseCampaignEndingDateTimestamp = 1709084568;
    uint32 public constant inFundingPhaseEstimatedProjectReleaseDateTimestamp = 1711676568;

    // For project in realisation phase
    uint32 public constant inProgressCampaignStartingDateTimestamp = 1706924867;
    uint32 public constant inProgressCampaignEndingDateTimestamp = 1707788867;
    uint32 public constant inProgressEstimatedProjectReleaseDateTimestamp = 1712972867;

    // For futur project
    uint32 public constant futureCampaignStartingDateTimestamp = 1709948568;
    uint32 public constant futurecampaignEndingDateTimestamp = 1710812568;
    uint32 public constant futurePhaseestimatedProjectReleaseDateTimestamp = 1713404568;


    function getMockedProjectDatas() public view returns(BlockFundingProject.ProjectData[] memory) {
        BlockFundingProject.ProjectData[] memory mockedData = new BlockFundingProject.ProjectData[](3);

        mockedData[0] = BlockFundingProject.ProjectData(
            inFundingPhaseCampaignStartingDateTimestamp,
            inFundingPhaseCampaignEndingDateTimestamp,
            inFundingPhaseEstimatedProjectReleaseDateTimestamp,
            targetWallet,
            msg.sender,
            0,
            BlockFunding.ProjectCategory.automobile,
            "AeroMagnet Drive",
            unicode'Une révolution en mobilité : AeroMagnet Drive, la première voiture volante propulsée par réacteurs, flottant grâce au magnétisme terrestre.',
            unicode"AeroMagnet Drive : L'Avenir de la Mobilité\n\nDans un monde en constante évolution, la mobilité a toujours été au cœur des préoccupations humaines. Aujourd'hui, nous sommes à l'aube d'une révolution : l'AeroMagnet Drive, un projet audacieux visant à concrétiser le rêve de la voiture volante. Inspirée par l'iconique Dolorean de la culture populaire, mais ancrée dans la réalité grâce à une technologie de pointe, l'AeroMagnet Drive promet de transformer notre manière de voyager.\n\nConception Innovante\n\nAu cœur de l'AeroMagnet Drive se trouvent quatre réacteurs innovants, situés aux emplacements traditionnels des roues. Ces réacteurs, s'inspirant de la technologie éprouvée des boosters d'Ariane 5, offrent une propulsion puissante et fiable, permettant à la voiture de s'élever au-dessus du sol. Une fois en lévitation, l'AeroMagnet Drive exploite le magnétisme terrestre pour flotter, garantissant un voyage doux et sans friction.\n\nTechnologie de Pointe\n\nLa clé de la flottaison de l'AeroMagnet Drive réside dans son système de magnétisme avancé. Utilisant des matériaux supraconducteurs et des aimants néodyme de haute intensité, ce système crée un champ magnétique puissant qui interagit avec le champ magnétique terrestre, permettant à la voiture de maintenir une lévitation stable. Cette approche, non seulement minimise l'usure mécanique mais ouvre également la porte à des vitesses de déplacement révolutionnaires, sans impact sur l'environnement.\n\nSécurité et Durabilité\n\nLa sécurité est au premier plan de l'AeroMagnet Drive. Avec des systèmes de navigation et de pilotage automatisés intégrant l'IA, la voiture est conçue pour anticiper et éviter les obstacles, garantissant une expérience de vol sûre. De plus, en utilisant des énergies propres pour la propulsion, l'AeroMagnet Drive se positionne comme une solution durable pour l'avenir de la mobilité, réduisant considérablement l'empreinte carbone des transports.\n\nVision du Projet\n\nL'AeroMagnet Drive n'est pas simplement une voiture ; c'est le symbole d'une nouvelle ère de mobilité, où les frontières entre le sol et le ciel s'estompent. En rendant le vol personnel accessible, ce projet vise à décongestionner les villes, réduire les temps de trajet et offrir une nouvelle liberté de mouvement, tout en préservant notre planète pour les générations futures.\n\nDéveloppement et Réalisation\n\nLe développement de l'AeroMagnet Drive se déroulera en plusieurs phases, depuis la conception initiale jusqu'à la production en série. Chaque étape sera marquée par des jalons spécifiques, incluant des tests rigoureux et l'obtention des certifications nécessaires pour garantir la conformité avec les normes de sécurité aérienne et routière.\n\nLe Futur de la Mobilité est à Portée de Main\n\nAvec l'AeroMagnet Drive, nous ne nous contentons pas de rêver du futur ; nous le construisons. Rejoignez-nous dans cette aventure et soyez aux premières loges de la révolution de la mobilité. Ensemble, nous pouvons redéfinir les limites du possible et ouvrir un nouveau chapitre dans l'histoire du voyage humain.",
            "https://image.noelshack.com/fichiers/2024/07/5/1708090363-bannerautomobile.jpg",
            getMockedTeamMembers(),
            getMockedStepsForAeroDrive());

        mockedData[1] = BlockFundingProject.ProjectData(
            inProgressCampaignStartingDateTimestamp,
            inProgressCampaignEndingDateTimestamp,
            futurePhaseestimatedProjectReleaseDateTimestamp,
            targetWallet,
            msg.sender,
            0,
            BlockFunding.ProjectCategory.technology,
            unicode"PizzaRenaissance",
            unicode"PizzaRenaissance est un innovant réhydrateur de pizza transformant une pizza déshydratée en une délicieuse pizza au goût frais et à la texture parfaite en quelques secondes.",
            unicode"PizzaRenaissance est la concrétisation d'un rêve pour tous les amateurs de pizza. Inspiré par la célèbre scène de 'Retour vers le Futur', notre projet vise à révolutionner la manière dont nous consommons notre plat favori. Le réhydrateur PizzaRenaissance est un appareil révolutionnaire capable de transformer une pizza déshydratée en une pizza chaude, savoureuse et croustillante en seulement quelques secondes, comme si elle sortait tout juste du four.\n\nLe secret de PizzaRenaissance réside dans sa technologie de pointe qui imite le processus de réhydratation rapide vu dans le film, tout en s'assurant que toutes les saveurs et la texture de la pizza soient méticuleusement préservées. Notre équipe de chercheurs et d'ingénieurs a travaillé sans relâche pour mettre au point un système qui utilise un mélange précis de chaleur, d'humidité et de pression pour réactiver les ingrédients déshydratés sans compromettre leur qualité ni leur goût.\n\nLe design de l'appareil PizzaRenaissance est à la fois moderne et compact, permettant de l'intégrer facilement dans n'importe quelle cuisine. Son interface utilisateur intuitive rend le processus de réhydratation accessible à tous, garantissant une expérience utilisateur sans faille. Que vous soyez pressé, que vous souhaitiez réduire le gaspillage alimentaire ou simplement profiter d'une pizza parfaite à tout moment, PizzaRenaissance est la solution idéale.\n\nNotre vision va au-delà de la simple réhydratation de la pizza. Nous envisageons un avenir où PizzaRenaissance jouera un rôle crucial dans la transformation de la manière dont nous appréhendons la conservation et la consommation des aliments. En rendant la déshydratation et la réhydratation des aliments plus efficaces et savoureuses, nous pouvons significativement réduire le gaspillage alimentaire tout en maximisant la commodité et le plaisir de manger.\n\nLe projet PizzaRenaissance se compose de plusieurs phases, allant de la recherche et développement à la production en série, en passant par les tests utilisateurs et le lancement sur le marché. Chaque étape est conçue pour garantir que le produit final soit non seulement innovant, mais aussi sûr, fiable et abordable. Nous nous engageons à utiliser des matériaux durables et à adopter des pratiques de fabrication responsables pour minimiser notre impact environnemental.\n\nEn participant à notre campagne de crowdfunding, vous ne soutenez pas seulement le lancement d'un produit révolutionnaire ; vous contribuez également à une vision plus large visant à changer notre relation avec la nourriture. Ensemble, nous pouvons redéfinir ce qu'il est possible de faire dans la cuisine, tout en prenant soin de notre planète.\n\nRejoignez-nous dans cette aventure culinaire et technologique et soyez parmi les premiers à découvrir le goût authentique de la pizza, réinventé par PizzaRenaissance. Votre soutien est crucial pour transformer cette vision en réalité. Ensemble, faisons revivre le goût et réinventons la pizza pour les générations à venir.",
            "https://image.noelshack.com/fichiers/2024/07/5/1708097743-dall-e-2024-02-16-16-32-03-genere-une-cuisine-eco-futuriste.jpg",
            getMockedTeamMembers(),
            getMockedStepsForPizzaRenaissance());

        mockedData[2] = BlockFundingProject.ProjectData(
            futureCampaignStartingDateTimestamp,
            futurecampaignEndingDateTimestamp,
            futurePhaseestimatedProjectReleaseDateTimestamp,
            targetWallet,
            msg.sender,
            0,
            BlockFunding.ProjectCategory.technology,
            "HoverSol",
            unicode"HoverSol est un hoverboard révolutionnaire qui flotte à 20 cm du sol, utilisant une combinaison d'énergie solaire, magnétisme terrestre, et énergie cinétique, pour une mobilité durable sans batterie.",
            unicode"Le projet HoverSol représente une avancée spectaculaire dans le domaine du transport personnel, inspiré par la vision futuriste du célèbre film 'Retour vers le Futur'. Conçu pour flotter à environ 20 cm au-dessus de n'importe quel type de sol, HoverSol marque le début d'une nouvelle ère de mobilité urbaine, où l'efficacité énergétique et le respect de l'environnement sont à l'avant-garde.\n\nInnovation et Technologie\n\nHoverSol intègre des technologies de pointe pour réaliser ce qui était autrefois considéré comme de la science-fiction. En exploitant l'énergie solaire, le magnétisme terrestre, et l'énergie cinétique, HoverSol fonctionne entièrement sans batteries traditionnelles, éliminant le besoin de recharge électrique et réduisant significativement l'impact environnemental associé à la production et au recyclage des batteries.\n\nLes panneaux solaires ultra-efficaces couvrent la surface du hoverboard, captant l'énergie solaire qui est convertie en électricité. Cette électricité alimente un système de lévitation magnétique innovant, qui utilise les propriétés du magnétisme terrestre pour créer une force répulsive stable, permettant à HoverSol de léviter au-dessus du sol. L'énergie cinétique générée par le mouvement de l'hoverboard est également récupérée, fournissant une source d'énergie supplémentaire pour le système.\n\nDéveloppement Durable\n\nHoverSol est conçu avec un engagement profond envers le développement durable. En plus de son fonctionnement sans batterie, l'utilisation de matériaux écologiques et recyclables pour sa construction minimise davantage son empreinte écologique. Ce projet incarne l'idéal d'une technologie qui non seulement avance les possibilités humaines mais le fait de manière responsable.\n\nDesign et Fonctionnalités\n\nLe design de HoverSol est à la fois moderne et fonctionnel, offrant une expérience utilisateur intuitive et agréable. Sa plateforme robuste assure une stabilité et une sécurité maximales, tandis que son système de contrôle facile à utiliser rend la navigation fluide et réactive, adaptée à tous les âges et niveaux d'expérience.\n\nSécurité\n\nLa sécurité est une priorité absolue pour HoverSol. Des capteurs avancés et un système de contrôle automatisé surveillent en permanence la stabilité et l'altitude, ajustant dynamiquement la force magnétique pour garantir une lévitation sûre et stable, même sur des surfaces irrégulières.\n\nImpact Social et Urbain\n\nHoverSol a le potentiel de transformer radicalement les paysages urbains en offrant une alternative propre et efficace aux modes de transport conventionnels. En réduisant la dépendance aux véhicules motorisés, HoverSol contribue à diminuer la congestion urbaine et la pollution atmosphérique, favorisant un environnement urbain plus sain et plus agréable.",
            "https://image.noelshack.com/fichiers/2024/07/7/1708222390-dall-e-2024-02-18-03-11-51-genere-une-ville-futuriste.jpg",
            getMockedTeamMembers(),
            getMockedStepsForHoverSol());

        return mockedData;
    }

    function getMockedTeamMembers() internal pure returns(BlockFundingProject.TeamMember[] memory) {
        BlockFundingProject.TeamMember[] memory mockedData = new BlockFundingProject.TeamMember[](3);

        // Premier membre de l'équipe
        mockedData[0] = BlockFundingProject.TeamMember({
            firstName: "Alice",
            lastName: "Doe",
            description: "Lead Developer with extensive experience in blockchain technology.",
            photoLink: "https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=1200",
            role: "Lead Developer",
            walletAddress: 0x0B89257b0ee39f7B60E97b1304fd8a4fC031B395 
        });

        // Deuxième membre de l'équipe
        mockedData[1] = BlockFundingProject.TeamMember({
            firstName: "Bob",
            lastName: "Smith",
            description: "Project Manager with a decade of industry experience.",
            photoLink: "https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg?auto=compress&cs=tinysrgb&w=1200",
            role: "Project Manager",
            walletAddress: 0x01beB3F1727Ca50a55ee8875c8178b59362E5E21
        });

        // Troisième membre de l'équipe
        mockedData[2] = BlockFundingProject.TeamMember({
            firstName: "Charlie",
            lastName: "Brown",
            description: "Creative Director with a keen eye for design.",
            photoLink: "https://images.pexels.com/photos/1043474/pexels-photo-1043474.jpeg?auto=compress&cs=tinysrgb&w=1200",
            role: "Creative Director",
            walletAddress: 0x9cc62Fa77F34b7EB235cBA358E6177e8868512c3
        });

        return mockedData;
    }

    function getMockedProjectSteps() internal pure returns(BlockFundingProject.ProjectStep[] memory) {
        BlockFundingProject.ProjectStep[] memory mockedData = new BlockFundingProject.ProjectStep[](5);

        mockedData[0] = BlockFundingProject.ProjectStep({
            name: "Conceptualization",
            description: "Defining the project scope and its feasibility.",
            amountNeeded: 1000000,
            amountFunded: 500000,
            isFunded: false,
            orderNumber: 1,
            hasBeenValidated: false
        });

        mockedData[1] = BlockFundingProject.ProjectStep({
            name: "Design",
            description: "Creating detailed designs and specifications.",
            amountNeeded: 2000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 2,
            hasBeenValidated: false
        });

        mockedData[2] = BlockFundingProject.ProjectStep({
            name: "Development",
            description: "Development phase to build and test the project.",
            amountNeeded: 3000000,
            amountFunded: 1500000,
            isFunded: false,
            orderNumber: 3,
            hasBeenValidated: false
        });

        mockedData[3] = BlockFundingProject.ProjectStep({
            name: "Testing",
            description: "Rigorous testing to ensure quality and performance.",
            amountNeeded: 500000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 4,
            hasBeenValidated: false
        });

        mockedData[4] = BlockFundingProject.ProjectStep({
            name: "Launch",
            description: "Official launch of the project to the public.",
            amountNeeded: 1000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 5,
            hasBeenValidated: false
        });

        return mockedData;
    }

    function getMockedStepsForAeroDrive() internal pure returns(BlockFundingProject.ProjectStep[] memory) {
        BlockFundingProject.ProjectStep[] memory mockedData = new BlockFundingProject.ProjectStep[](12);

        mockedData[0] = BlockFundingProject.ProjectStep({
            name: "Conceptualisation et Design Initial",
            description: unicode"Élaboration du concept, études de faisabilité, et design préliminaire.",
            amountNeeded: 1000000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 1,
            hasBeenValidated: false
        });

        mockedData[1] = BlockFundingProject.ProjectStep({
            name: unicode"Modélisation et Simulation",
            description: unicode"Modélisation numérique et simulation des performances de vol et de lévitation.",
            amountNeeded: 2000000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 2,
            hasBeenValidated: false
        });

        mockedData[2] = BlockFundingProject.ProjectStep({
            name: unicode"Développement des Réacteurs",
            description: unicode"Conception et prototype des réacteurs de propulsion.",
            amountNeeded: 7000000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 3,
            hasBeenValidated: false
        });

        mockedData[3] = BlockFundingProject.ProjectStep({
            name: unicode"Système de Lévitation Magnétique",
            description: unicode"Développement et test du système de lévitation.",
            amountNeeded: 10000000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 4,
            hasBeenValidated: false
        });

        mockedData[4] = BlockFundingProject.ProjectStep({
            name: "Prototype Initial",
            description: unicode"Construction du premier prototype fonctionnel.",
            amountNeeded: 2000000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 5,
            hasBeenValidated: false
        });

        mockedData[5] = BlockFundingProject.ProjectStep({
            name: "Essais en Vol",
            description: unicode"Premiers tests de vol et ajustements basés sur les résultats.",
            amountNeeded: 2000000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 6,
            hasBeenValidated: false
        });

        mockedData[6] = BlockFundingProject.ProjectStep({
            name: unicode"Sécurité et Conformité",
            description: unicode"Vérification de la sécurité et démarches pour la conformité réglementaire.",
            amountNeeded: 3000000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 7,
            hasBeenValidated: false
        });

        mockedData[7] = BlockFundingProject.ProjectStep({
            name: unicode"Optimisation et Révisions",
            description: unicode"Amélioration du design et des systèmes en fonction des tests.",
            amountNeeded: 3000000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 8,
            hasBeenValidated: false
        });

        mockedData[8] = BlockFundingProject.ProjectStep({
            name: unicode"Pré-Production",
            description: unicode"Mise en place des lignes de production et préparation pour la fabrication.",
            amountNeeded: 5000000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 9,
            hasBeenValidated: false
        });

        mockedData[9] = BlockFundingProject.ProjectStep({
            name: "Campagne de Marketing",
            description: unicode"Lancement d'une campagne pour sensibiliser et attirer les premiers acheteurs.",
            amountNeeded: 4000000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 10,
            hasBeenValidated: false
        });

        mockedData[10] = BlockFundingProject.ProjectStep({
            name: unicode"Production de Série",
            description: unicode"Début de la production en série et contrôle qualité.",
            amountNeeded: 10000000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 11,
            hasBeenValidated: false
        });

        mockedData[11] = BlockFundingProject.ProjectStep({
            name: "Lancement et Commercialisation",
            description: unicode"Lancement officiel sur le marché et début des livraisons.",
            amountNeeded: 1000000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 12,
            hasBeenValidated: false
        });

        return mockedData;
    }

    function getMockedStepsForPizzaRenaissance() internal pure returns(BlockFundingProject.ProjectStep[] memory) {
        BlockFundingProject.ProjectStep[] memory mockedData = new BlockFundingProject.ProjectStep[](7);

        mockedData[0] = BlockFundingProject.ProjectStep({
            name: unicode"Conception et Développement ",
            description: unicode"Fusion des phases de recherche, de développement initial, et de prototypage. Cette étape inclut l'étude de faisabilité, la conception préliminaire, le développement de prototypes pour tester la technologie de réhydratation, et les analyses initiales pour optimiser la performance.",
            amountNeeded: 1000000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 1,
            hasBeenValidated: false
        });

        mockedData[1] = BlockFundingProject.ProjectStep({
            name: unicode"Tests et Optimisation",
            description: unicode"Combinaison des tests de laboratoire et du développement logiciel, cette étape se concentre sur les analyses approfondies pour optimiser la performance, la sécurité du dispositif, et la création du logiciel de contrôle, y compris l'interface utilisateur.",
            amountNeeded: 2000000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 2,
            hasBeenValidated: false
        });

        mockedData[2] = BlockFundingProject.ProjectStep({
            name: unicode"Finalisation du Design et Certification",
            description: unicode"Cette étape intègre le design industriel final et l'obtention des certifications nécessaires pour la commercialisation, assurant que le produit respecte toutes les normes et régulations applicables.",
            amountNeeded: 7000000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 3,
            hasBeenValidated: false
        });

        mockedData[3] = BlockFundingProject.ProjectStep({
            name: unicode"Préparation de la Production",
            description: unicode"Mise en place simultanée de la chaîne de production, incluant l'établissement des lignes de production et des partenariats avec les fournisseurs.",
            amountNeeded: 10000000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 4,
            hasBeenValidated: false
        });

        mockedData[4] = BlockFundingProject.ProjectStep({
            name: "Production de Masse",
            description: unicode"Début de la fabrication en grande quantité pour répondre à la demande prévue, en utilisant les fonds collectés lors de la campagne de crowdfunding pour financer cette phase.",
            amountNeeded: 2000000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 5,
            hasBeenValidated: false
        });

        mockedData[5] = BlockFundingProject.ProjectStep({
            name: unicode"Marketing et Lancement sur le Marché",
            description: unicode"Planification et exécution des campagnes de marketing pour promouvoir le produit, suivies du lancement sur le marché, en s'assurant que les stratégies de publicité sont en place pour atteindre le public cible.",
            amountNeeded: 2000000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 6,
            hasBeenValidated: false
        });

        mockedData[6] = BlockFundingProject.ProjectStep({
            name: unicode"Distribution et Ventes",
            description: unicode"Mise en place de la logistique pour la distribution et gestion des ventes, en s'assurant que le produit est accessible aux consommateurs à travers différents canaux de vente, y compris en ligne et en magasin.",
            amountNeeded: 3000000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 7,
            hasBeenValidated: false
        });

        return mockedData;
    }

    function getMockedStepsForHoverSol() internal pure returns(BlockFundingProject.ProjectStep[] memory) {
        BlockFundingProject.ProjectStep[] memory mockedData = new BlockFundingProject.ProjectStep[](9);

        mockedData[0] = BlockFundingProject.ProjectStep({
            name: unicode"Étude de Faisabilité et Recherche Initiale",
            description: unicode"Analyse approfondie des technologies existantes. Exploration des innovations en matière d'énergie solaire, magnétisme et récupération d'énergie cinétique",
            amountNeeded: 100000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 1,
            hasBeenValidated: false
        });

        mockedData[1] = BlockFundingProject.ProjectStep({
            name: unicode"Conception et Développement de Prototypes",
            description: unicode"Création de designs préliminaires. Fabrication et test de plusieurs prototypes pour évaluer différentes configurations.",
            amountNeeded: 150000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 2,
            hasBeenValidated: false
        });

        mockedData[2] = BlockFundingProject.ProjectStep({
            name: unicode"Tests de Sécurité et Optimisation",
            description: unicode"Évaluation rigoureuse de la sécurité. Optimisation de la technologie de lévitation et des systèmes d'énergie",
            amountNeeded: 100000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 3,
            hasBeenValidated: false
        });

        mockedData[3] = BlockFundingProject.ProjectStep({
            name: unicode"Développement de Logiciels et d'Interface Utilisateur",
            description: unicode"    Création d'une interface utilisateur intuitive. Développement de logiciels pour le contrôle de la stabilité et de la navigation",
            amountNeeded: 5000000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 4,
            hasBeenValidated: false
        });

        mockedData[4] = BlockFundingProject.ProjectStep({
            name: unicode"Production de Pré-série et Tests du Marché",
            description: unicode"Fabrication d'une petite série pour des tests utilisateur étendus. Collecte de feedback et ajustements basés sur les retours des utilisateurs",
            amountNeeded: 100000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 5,
            hasBeenValidated: false
        });

        mockedData[5] = BlockFundingProject.ProjectStep({
            name: unicode"Campagne de Marketing et de Crowdfunding",
            description: unicode"Préparation et exécution d'une campagne de crowdfunding pour financer la production de masse",
            amountNeeded: 8000000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 6,
            hasBeenValidated: false
        });

        mockedData[6] = BlockFundingProject.ProjectStep({
            name: unicode"Mise en Place de la Ligne de Production",
            description: unicode"Installation des équipements de production. Formation de l'équipe de production",
            amountNeeded: 120000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 7,
            hasBeenValidated: false
        });

        mockedData[7] = BlockFundingProject.ProjectStep({
            name: unicode"Lancement Commercial",
            description: unicode"Production en masse. Distribution et vente aux premiers adopteurs",
            amountNeeded: 5000000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 8,
            hasBeenValidated: false
        });

        mockedData[8] = BlockFundingProject.ProjectStep({
            name: unicode"Suivi et Amélioration Continue",
            description: unicode"Évaluation continue du produit sur le marché. Recherche et développement pour des améliorations futures et des innovations additionnelles",
            amountNeeded: 100000000000000000000,
            amountFunded: 0,
            isFunded: false,
            orderNumber: 9,
            hasBeenValidated: false
        });

        return mockedData;
    }

    /// @dev I add this line to make forge coverage ignore this class
    function test() public {}
}