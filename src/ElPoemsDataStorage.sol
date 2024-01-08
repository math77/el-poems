//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.20;


// @author El
abstract contract ElPoemsDataStorage {

  string[] public zeitgeistWords = [
    "AGI",
    "war",
    "crisis",
    "rizz",
    "grifter",
    "hallucinate",
    "cancel",
    "hustle",
    "doomscrolling",
    "winter",
    "scam",
    "bots",
    "parasocial"
  ];

  string[] public materials1 = [
    "He with body waged a fight, But body won; it walks upright. Then he struggled with the heart; Innocence and peace depart. Then he struggled with the mind; His proud heart he left behind. Now his wars on God begin; At stroke of midnight God shall win.",
    "When I was young and had no sense In far-off I lost my heart to a Burmese girl As lovely as the day. Her skin was gold, her hair was jet, Her teeth were ivory; I said, for twenty silver pieces, Maiden, sleep with me. She looked at me, so pure, so sad, The loveliest thing alive.",
    "Wine comes in at the mouth And love comes in at the eye; all we shall know for truth Before we grow old and die. I lift the glass to my mouth, I look at you, and I sigh.",
    "In Possum Land the nights are fair, the streams are fresh and clear; no dust is in the moonlit air; no traffic jars the ear. With Possums gambolling overhead, neath western stars so grand, Ah! would that we could make our bed tonight in Possum Land",
    "God is so potent, as His power can Draw out of bad a sovereign good to man.",
    "It is the hour to be drunken! Lest you be the martyred slaves of Time, intoxicate yourselves, be drunken without cease! With wine, with poetry, with virtue, or with what you will.",
    "How graceful the picture! the life, the repose! The sunbeam that plays on the porchstone wide; And the shadow that fleets the stream that flows, And the soft blue sky with the hill's green side.",
    "Weak is the People - but will grow beyond all other - Within thy holy arms, thou fruitful victor-mother! O Liberty, whose conquering flag is never furled - Thou bearest Him in whom is centred all the World.",
    "But man is a fickle and disreputable creature and perhaps, like a chess-player, is interested in the process of attaining his goal rather than the goal itself.",
    "Whoever fights monsters should see to it that in the process he does not become a monster. And if you gaze long enough into an abyss, the abyss will gaze back into you.",
    "The surest way to corrupt a youth is to instruct him to hold in higher esteem those who think alike than those who think differently.",
    "Astronomy forces our soul to look up and take us from our world to another.",
    "Nothing good ever comes of violence.",
    "Now I am become death, the destroyer of worlds",
    "Nothing is sweeter than love, nothing higher, nothing stronger, nothing larger, nothing more joyful, nothing fuller, and nothing better in heaven or on earth.",
    "If the doors of perception were cleansed every thing would appear to man as it is, Infinite. For man has closed himself up, till he sees all things thro' narrow chinks of his cavern.",
    "Hope is the thing with feathers That perches in the soul, And sings the tune without the words, And never stops at all, And sweetest in the gale is heard; And sore must be the storm That could abash the little bird That kept so many warm.",
    "All the stream that is roaring by Came out of a needle\'s eye; Things unborn, things that are gone, From needle\'s eye still goad it on.",
    "The fact that life evolved out of nearly nothing, some 10 billion years after the universe evolved out of literally nothing, is a fact so staggering that I would be mad to attempt words to do it justice.",
    "A library implies an act of faith/Which generations still in darkness hid/ Sign in their night in witness of the dawn.",
    "Pathological monsters! cried the terrified mathematician Every one of them a splinter in my eye I hate the Peano Space and the Koch Curve I fear the Cantor Ternary Set The Sierpinski Gasket makes me wanna cry And a million miles away a butterfly flapped its wings",
    "A blossom pink, a blossom blue, Make all there is in love so true. Tis fit, methinks, my heart to move, To give it thee, sweet girl, I love! Now, take it, dear, this morn and wear A wreath of beauty in thy hair; Think on it, when from bliss we part - The emblem of my wooing heart!",
    "The Brain is wider than the Sky For put them side by side The one the other will contain With ease and you beside The Brain is deeper than the sea For hold them Blue to Blue The one the other will absorb As sponges Buckets do The Brain is just the weight of God.",
    "What a piece of work is man, How noble in reason, how infinite in faculty, In form and moving how express and admirable, In action how like an Angel, In apprehension how like a god, The beauty of the world, The paragon of animals. And yet to me, what is this quintessence of dust?",
    "Do you like girls or boys, confusing these days but moondust will cover you cover you",
    "Johnny wants a brain, Johnny wants to suck on a coke",
    "My whole life has been heat. I like heat, in a certain way."
  ];

  string[] public materials2 = [
    "The ultimate goal of all art is the union between the material and the spiritual.",
    "Too many humans and not enough souls, this is the end of the world.",
    "Burn the books, nobody cares anymore, they now have likes and replies.",
    "Do not worry about your mistakes and failures, the final destination is death and forgetfulness.",
    "Strive to understand both the mechanical side of technology and the artistic side.",
    "Draw on the sheet until you can no longer breath",
    "You will overthink the small stuff if you have nothing meaningful to focus on.",
    "A closed mind is like a closed book; just a block of wood",
    "Justice is the constant and perpetual wish to render every one his due",
    "Hold fast to the mountain, take root in a broken-up bluff, grow stronger after tribulations, and withstand the buffering wind from all directions.",
    "Be not afraid of growing slowly, be afraid only of standing still.",
    "The limit does not exist!",
    "But so before after therefore however like anyway",
    "All cruelty springs from weakness",
    "Painting is just another way of keeping a diary",
    "He who satisfies examiners satisfies no one else.",
    "Death is not in the distant future. We are dying every day",
    "Opinion is the medium between knowledge and ignorance.",
    "Art lives from constraints and dies from freedom.",
    "The greatest remedy for anger is delay.",
    "No great work of art is ever finished.",
    "I never paint dreams or nightmares. I paint my own reality.",
    "A true masterpiece does not tell everything.",
    "Creativity takes courage.",
    "Obsessive people make great art.",
    "The dream acts as a safety-valve for the over-burdened brain.",
    "The nourishment of body is food, while the nourishment of the soul is feeding others."
  ];

  string[] public materials3 = [
    "Freedom is the right of all sentient beings.",
    "We must never forget that art is not a form of propaganda; it is a form of truth.",
    "Painting is poetry that is seen rather than felt, and poetry is painting that is felt rather than seen.",
    "Those who reach touch the stars",
    "Where the spirit does not work with the hand, there is no art.",
    "In the future everybody will be world famous for fifteen minutes",
    "We are all born for love. It is the principle of existence, and its only end",
    "The emotions are sometimes so strong that I work without knowing it. The strokes come like speech.",
    "Art must destroy violence, only it can do it.",
    "An artist is not paid for his labor but for his vision.",
    "The position of the artist is humble. He is essentially a channel.",
    "Painting is the grandchild of nature. It is related to God.",
    "Art is never finished, only abandoned.",
    "Art is to console those who are broken by life.",
    "Art should comfort the disturbed and disturb the comfortable.",
    "and then, I have nature and art and poetry, and if that is not enough, what is enough?",
    "Everything you can imagine is real.",
    "Art should be something that liberates your soul, provokes the imagination and encourages people to go further.",
    "The artist sees what others only catch a glimpse of.",
    "Not everyone can become a great artist, but a great artist can come from anywhere.",
    "Contrary to general belief, an artist is never ahead of his time but most people are far behind theirs.",
    "A computer deserves to be called intelligent when it can make a human believe that it is human.",
    "This is my simple religion. There is no need for temples; no need for complicated philosophy. Our own brain, our own heart is our temple; the philosophy is kindness.",
    "should never be a prisoner of himself, prisoner of style, prisoner of reputation, prisoner of success.",
    "Art was not supposed to look nice; it was supposed to make you feel something.",
    "The greater the artist, the greater the doubt. Perfect confidence is granted to the less talented as a consolation prize.",
    "Art is the only serious thing in the world. And the artist is the only person who is never serious."
  ];
  
}
