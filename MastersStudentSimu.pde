Player player;
ArrayList<Enemy> enemies;
ArrayList<Beam> beams;
int score = 0;
int life = 5;
int initial_enemy_count = 60;
float percolationTime = -1;  // Variable to store the time of percolation
int CNT_THRES = 10;  // Threshold for the number of hits
int PERCOLATION_BONUS = 100;  // Bonus points for percolation
PImage[] enemyImages;
PImage[] playerImages;
// String[] enemyNames;

void setup() {
    size(800, 600);
    beams = new ArrayList<Beam>();
    
    // Create enemies
    enemies = new ArrayList<Enemy>();
    enemyImages = new PImage[5];
    String[] enemyNames = {"nomi", "kadai", "in", "ju", "ken"};
    for (int i = 0; i < enemyImages.length; i++) {
        enemyImages[i] = loadImage("images/" + enemyNames[i] + ".png");  // Assumes the images are named "enemy0.png", "enemy1.png", etc.
    }
    for (int i = 0; i < initial_enemy_count; i++) {
        PImage ememyImage = enemyImages[(int) random(enemyImages.length)];
        enemies.add(new Enemy(random(width), random(0, 0), random(1, 5),ememyImage));
    }
    
    // Create player
    playerImages = new PImage[2];
    String[] playerNames = {"takai", "hikui"};
    for (int i = 0; i < playerImages.length; i++) {
        playerImages[i] = loadImage("images/" + playerNames[i] + ".png");  // Assumes the images are named "enemy0.png", "enemy1.png", etc.
    }
    player = new Player(width / 2, height - 50, playerImages[0]);
    
}

void draw() {
    background(0);
    player.display();
    player.move();
    displayScore();
    displayLife();
    
    for (int i = enemies.size() - 1; i >= 0; i--) {
        Enemy e = enemies.get(i);
        e.move();
        e.display();
        
        if (e.hits(player)) {
            e.reset();
            life -= 1;
        }
        
        for (int j = beams.size() - 1; j >= 0; j--) {
            Beam b = beams.get(j);
            if (b.hits(e)) {
                // beams.remove(j);
                e.reset();
                score += 1;
                b.hit();
                
                if (b.getHitCount() == CNT_THRES) {
                    percolationTime = millis();
                    score += PERCOLATION_BONUS;
                }
                
                break;
            }
        }
    }
    
    for (int i = beams.size() - 1; i >= 0; i--) {
        Beam b = beams.get(i);
        b.move();
        b.display();
        
        if (b.offscreen()) {
            beams.remove(i);
        }
    }
    // If percolation occurred less than 1 second ago, display the message
    if (millis() - percolationTime <= 1000) {
        fill(255);
        textSize(32);
        text("Percolation!", width / 2, height / 2);
    }
}

void mousePressed() {
    Beam b = new Beam(player.x, player.y);
    beams.add(b);
}

class Player {
    float x;
    float y;
    PImage img;
    
    Player(float x, float y, PImage img) {
        this.x = x;
        this.y = y;
        this.img = img;
    }
    
    void display() {
        if (life > 3) {
            img = playerImages[0];
        } else {
            img = playerImages[1];
        }
        image(img, x, y, 50, 50);
    }
    
    void move() {
        x = mouseX;
    }
}

class Enemy {
    float x;
    float y;
    float speed;
    PVector direction;
    PImage img;
    
    Enemy(float x, float y, float speed, PImage img) {
        this.x = x;
        this.y = y;
        this.speed = speed;
        direction = new PVector(0, 1);
        this.img = img;
    }
    
    void reset() {
        x = random(width);
        y = random( -200, -300);
        speed = random(1, 5);
        direction = new PVector(0, 1); // Always move down
    }
    
    void move() {
        x += direction.x * speed;
        y += direction.y * speed;
        
        // Wrap around the screen (Percolation), but not from the bottom
        if (x < 0) x = width;
        if (x > width) x = 0;
        if (y < 0) y = random( -200, 0);
        if (y > height) reset(); // Reset position and direction
    }
    
    void display() {
        image(img, x, y, 30, 30);
    }
    
    boolean hits(Player p) {
        float d = dist(x, y, p.x, p.y);
        return(d < 40);
    }
}

class Beam {
    float x;
    float y;
    float speed;
    int hitCount;
    
    Beam(float x, float y) {
        this.x = x;
        this.y = y;
        this.speed = 10;
        this.hitCount = 0;
    }
    
    void move() {
        y -= speed;
    }
    
    void display() {
        fill(255);
        rect(x , y, 50, 20);
    }
    
    boolean offscreen() {
        return(y < 0);
    }
    
    boolean hits(Enemy e) {
        float d = dist(x, y, e.x, e.y);
        return(d < 60);
    }
    
    void hit() {
        hitCount++;
    }
    
    int getHitCount() {
        return hitCount;
    }
}

void displayScore() {
    fill(255);
    textSize(24);
    text("Score: " + score, 20, 30);
}

void displayLife() {
    fill(255);
    textSize(24);
    text("Life: " + life, 20, 60);
    
    if (life <= 0) {
        text("Game Over!", width / 2, height / 2);
        noLoop();  // stop the game
    }
}
