import derelict.sdl2.sdl;
import derelict.sdl2.image;
import std.stdio;
import std.random;

void main()
{
	//ladataan tarvittavat kirjastot
	DerelictSDL2.load();
	DerelictSDL2Image.load();
	
	//alustetaan madon osille sekä ruualle omat leimasimet/piirtäjät.
	SDL_Rect snake_sprite_drawer;
	SDL_Rect food_sprite_drawer;
	
	//alustetaan ikkuna ja ikkunaan piirtävä moottori renderer, sekä ladataan madon osa -ja ruokaspritet.
	auto window = SDL_CreateWindow("Matopeli", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 452, 452, 0);
	auto renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_PRESENTVSYNC);
	auto snake_piece_texture = IMG_LoadTexture(renderer, "snake_piece.png");
	auto food_texture = IMG_LoadTexture(renderer, "food.png");
	
	//alustetaan madon oletussuunta, pisteet ja madon oletusnopeus millisekunteina.
	Direction direction = Direction.Right;
	uint score = 0;
	uint delay = 110;
	
	//luodaan struct-taulukko, jossa jokainen paikka sisältää madon osan xy-koordinaatit.
	//taulukko[0] on madon pää, jne.
	auto snake_pieces = new SnakePiece[0];
	snake_pieces ~= SnakePiece(31, 1);
	snake_pieces ~= SnakePiece(21, 1);
	snake_pieces ~= SnakePiece(11, 1);
	snake_pieces ~= SnakePiece(1, 1);
	
	//alustetaan ja asetetaan random xy-koordinaattiarvot ruualle, sekä luodaan uusi ruoka-structi näillä.
	auto food_x_rand = uniform(1, 445);
	auto food_y_rand = uniform(1, 445);
	auto food = new Food(food_x_rand, food_y_rand);
	food.x = food_x_rand;
	food.y = food_y_rand;
	
	//luodaan pelin pääluuppi.
	SDL_Event event;
	while(true)
	{
		//luodaan näppäintenkuuntelu-luuppi, jossa nuolinäppäinten painalluksella voidaan asettaa madon
		//suunta-muuttuja.
		while(SDL_PollEvent(&event))
		{
			if(event.type == SDL_KEYDOWN)
			{
				if(event.key.keysym.sym == SDLK_DOWN)
				{
					direction = Direction.Down;
				}
				else if(event.key.keysym.sym == SDLK_LEFT)
				{
					direction = Direction.Left;
				}
				else if(event.key.keysym.sym == SDLK_UP)
				{
					direction = Direction.Up;
				}
				else if(event.key.keysym.sym == SDLK_RIGHT)
				{
					direction = Direction.Right;
				}
				else if(event.key.keysym.sym == SDLK_ESCAPE)
				{
					return;
				}
			}
			else if(event.type == SDL_QUIT)
			{
				return;
			}
		}
		
		for(auto i = snake_pieces.length-1; i > 0; --i)
		{
			snake_pieces[i].x = snake_pieces[i-1].x;
			snake_pieces[i].y = snake_pieces[i-1].y;
		}
		
		if(direction == Direction.Right)
		{
			snake_pieces[0].x += 10;
		}
		else if(direction == Direction.Down)
		{
			snake_pieces[0].y += 10;
		}
		else if(direction == Direction.Left)
		{
			snake_pieces[0].x -= 10;
		}
		else if(direction == Direction.Up)
		{
			snake_pieces[0].y -= 10;
		}
		
		SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
		SDL_RenderClear(renderer);
		
		food_sprite_drawer.w = 6;
		food_sprite_drawer.h = 6;
		food_sprite_drawer.x = food.x;
		food_sprite_drawer.y = food.y;	
		SDL_RenderCopy(renderer, food_texture, null, &food_sprite_drawer);
		
		snake_sprite_drawer.w = 9;
		snake_sprite_drawer.h = 9;
		foreach(snake_piece; snake_pieces)
		{
			snake_sprite_drawer.x = snake_piece.x;
			snake_sprite_drawer.y = snake_piece.y;
			
			
			if(SDL_HasIntersection(&snake_sprite_drawer, &food_sprite_drawer))
			{
				food_x_rand = uniform(1, 445);
				food_y_rand = uniform(1, 445);
				food.x = food_x_rand;
				food.y = food_y_rand;
				food_sprite_drawer.w = 6;
				food_sprite_drawer.h = 6;
				food_sprite_drawer.x = food.x;
				food_sprite_drawer.y = food.y;	
				SDL_RenderCopy(renderer, food_texture, null, &food_sprite_drawer);
				
				if(direction == Direction.Right)
				{
					snake_pieces ~= SnakePiece(snake_pieces[snake_pieces.length-1].x-10, 1);
				}
				else if(direction == Direction.Left)
				{
					snake_pieces ~= SnakePiece(snake_pieces[snake_pieces.length-1].x+10, 1);
				}
				else if(direction == Direction.Down)
				{
					snake_pieces ~= SnakePiece(1, snake_pieces[snake_pieces.length-1].y-10);
				}
				else if(direction == Direction.Up)
				{
					snake_pieces ~= SnakePiece(1, snake_pieces[snake_pieces.length-1].y+10);
				}
				
				delay -= 1;
				score += 1;
				writeln(score);
			}
			
			SDL_RenderCopy(renderer, snake_piece_texture, null, &snake_sprite_drawer);
		}
				
		SDL_RenderPresent(renderer);
		SDL_Delay(delay);
	}
}
enum Direction : ubyte
{
	Left,
	Right,
	Up,
	Down
}
struct SnakePiece
{
	uint x;
	uint y;
}
struct Food
{
	uint x;
	uint y;
}

