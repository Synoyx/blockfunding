// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "../../src/BlockFunding.sol";
import "../../src/BlockFundingProject.sol";

library MockedData {
    address public constant targetWallet = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint32 public constant campaignStartingDateTimestamp = 1717901384;
    uint32 public constant campaignEndingDateTimestamp = 1718001384;
    uint32 public constant estimatedProjectReleaseDateTimestamp = 1719001384;

    function getMockedProjectDatas() public view returns(BlockFundingProject.ProjectData[] memory) {
        BlockFundingProject.ProjectData[] memory mockedData = new BlockFundingProject.ProjectData[](3);

        mockedData[0] = BlockFundingProject.ProjectData(
            campaignStartingDateTimestamp,
            campaignEndingDateTimestamp,
            estimatedProjectReleaseDateTimestamp,
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
            campaignStartingDateTimestamp,
            campaignEndingDateTimestamp,
            estimatedProjectReleaseDateTimestamp,
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
            campaignStartingDateTimestamp,
            campaignEndingDateTimestamp,
            estimatedProjectReleaseDateTimestamp,
            targetWallet,
            msg.sender,
            0,
            BlockFunding.ProjectCategory.art,
            "Tech innovate",
            "Avancee en informatique",
            "Developpement d'un nouveau systeme d'exploration base sur la securite.",
            "https://i.pinimg.com/736x/d2/dc/d4/d2dcd4e515f401cc834e6ae5ba0dbd1a.jpg",
            getMockedTeamMembers(),
            getMockedProjectSteps());

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

    /// @dev I add this line to make forge coverage ignore this class
    function test() public {}
}