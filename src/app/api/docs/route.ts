import { NextResponse } from 'next/server';

const openApiSpec = {
  openapi: '3.0.0',
  info: {
    title: 'Aux API',
    description: 'Backend API for Aux - Universal Playlist Converter. Convert playlists between Spotify and Apple Music seamlessly.',
    version: '1.0.0',
    contact: {
      name: 'Aux Support',
      email: 'ayomideadekoya266@gmail.com',
      url: 'https://github.com/elcruzo/aux'
    }
  },
  servers: [
    {
      url: 'https://aux-50dr.onrender.com/api',
      description: 'Production server'
    },
    {
      url: 'http://localhost:3000/api',
      description: 'Local development server'
    }
  ],
  tags: [
    {
      name: 'Authentication',
      description: 'OAuth authentication endpoints'
    },
    {
      name: 'Spotify',
      description: 'Spotify playlist operations'
    },
    {
      name: 'Apple Music',
      description: 'Apple Music playlist operations'
    },
    {
      name: 'Conversion',
      description: 'Playlist conversion endpoints'
    }
  ],
  paths: {
    '/auth/status': {
      get: {
        tags: ['Authentication'],
        summary: 'Get authentication status',
        description: 'Check if user is authenticated with Spotify and Apple Music',
        responses: {
          '200': {
            description: 'Authentication status',
            content: {
              'application/json': {
                schema: {
                  $ref: '#/components/schemas/AuthStatus'
                }
              }
            }
          }
        }
      }
    },
    '/auth/spotify': {
      get: {
        tags: ['Authentication'],
        summary: 'Get Spotify OAuth URL',
        description: 'Get the Spotify OAuth authorization URL',
        responses: {
          '200': {
            description: 'OAuth URL',
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: {
                    url: {
                      type: 'string',
                      example: 'https://accounts.spotify.com/authorize?...'
                    }
                  }
                }
              }
            }
          }
        }
      }
    },
    '/auth/spotify/callback': {
      get: {
        tags: ['Authentication'],
        summary: 'Spotify OAuth callback',
        description: 'Handle Spotify OAuth callback',
        parameters: [
          {
            name: 'code',
            in: 'query',
            required: true,
            schema: {
              type: 'string'
            }
          },
          {
            name: 'state',
            in: 'query',
            required: false,
            schema: {
              type: 'string'
            }
          }
        ],
        responses: {
          '302': {
            description: 'Redirect to app'
          }
        }
      }
    },
    '/auth/apple/callback': {
      post: {
        tags: ['Authentication'],
        summary: 'Apple Music auth callback',
        description: 'Handle Apple Music authentication',
        requestBody: {
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  token: {
                    type: 'string'
                  }
                }
              }
            }
          }
        },
        responses: {
          '200': {
            description: 'Success'
          }
        }
      }
    },
    '/spotify/playlists': {
      get: {
        tags: ['Spotify'],
        summary: 'Get user\'s Spotify playlists',
        description: 'Fetch all playlists for authenticated Spotify user',
        security: [
          {
            cookieAuth: []
          }
        ],
        responses: {
          '200': {
            description: 'List of playlists',
            content: {
              'application/json': {
                schema: {
                  type: 'array',
                  items: {
                    $ref: '#/components/schemas/Playlist'
                  }
                }
              }
            }
          },
          '401': {
            $ref: '#/components/responses/Unauthorized'
          }
        }
      }
    },
    '/spotify/playlists/{playlistId}/tracks': {
      get: {
        tags: ['Spotify'],
        summary: 'Get playlist tracks',
        description: 'Get all tracks from a specific Spotify playlist',
        security: [
          {
            cookieAuth: []
          }
        ],
        parameters: [
          {
            name: 'playlistId',
            in: 'path',
            required: true,
            schema: {
              type: 'string'
            }
          }
        ],
        responses: {
          '200': {
            description: 'List of tracks',
            content: {
              'application/json': {
                schema: {
                  type: 'array',
                  items: {
                    $ref: '#/components/schemas/Track'
                  }
                }
              }
            }
          },
          '401': {
            $ref: '#/components/responses/Unauthorized'
          }
        }
      }
    },
    '/apple/playlists': {
      get: {
        tags: ['Apple Music'],
        summary: 'Get user\'s Apple Music playlists',
        description: 'Fetch all playlists for authenticated Apple Music user',
        security: [
          {
            cookieAuth: []
          }
        ],
        responses: {
          '200': {
            description: 'List of playlists',
            content: {
              'application/json': {
                schema: {
                  type: 'array',
                  items: {
                    $ref: '#/components/schemas/Playlist'
                  }
                }
              }
            }
          },
          '401': {
            $ref: '#/components/responses/Unauthorized'
          }
        }
      }
    },
    '/apple/playlists/{playlistId}/tracks': {
      get: {
        tags: ['Apple Music'],
        summary: 'Get playlist tracks',
        description: 'Get all tracks from a specific Apple Music playlist',
        security: [
          {
            cookieAuth: []
          }
        ],
        parameters: [
          {
            name: 'playlistId',
            in: 'path',
            required: true,
            schema: {
              type: 'string'
            }
          }
        ],
        responses: {
          '200': {
            description: 'List of tracks',
            content: {
              'application/json': {
                schema: {
                  type: 'array',
                  items: {
                    $ref: '#/components/schemas/Track'
                  }
                }
              }
            }
          },
          '401': {
            $ref: '#/components/responses/Unauthorized'
          }
        }
      }
    },
    '/convert': {
      post: {
        tags: ['Conversion'],
        summary: 'Convert playlist',
        description: 'Convert a playlist from one platform to another',
        security: [
          {
            cookieAuth: []
          }
        ],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                $ref: '#/components/schemas/ConversionRequest'
              }
            }
          }
        },
        responses: {
          '200': {
            description: 'Conversion result',
            content: {
              'application/json': {
                schema: {
                  $ref: '#/components/schemas/ConversionResult'
                }
              }
            }
          },
          '400': {
            $ref: '#/components/responses/BadRequest'
          },
          '401': {
            $ref: '#/components/responses/Unauthorized'
          }
        }
      }
    }
  },
  components: {
    schemas: {
      AuthStatus: {
        type: 'object',
        properties: {
          spotify: {
            type: 'boolean'
          },
          apple: {
            type: 'boolean'
          }
        }
      },
      Playlist: {
        type: 'object',
        properties: {
          id: {
            type: 'string'
          },
          name: {
            type: 'string'
          },
          description: {
            type: 'string',
            nullable: true
          },
          imageUrl: {
            type: 'string',
            nullable: true
          },
          trackCount: {
            type: 'integer'
          },
          owner: {
            type: 'string'
          },
          platform: {
            type: 'string',
            enum: ['spotify', 'apple']
          }
        }
      },
      Track: {
        type: 'object',
        properties: {
          id: {
            type: 'string'
          },
          name: {
            type: 'string'
          },
          artist: {
            type: 'string'
          },
          album: {
            type: 'string'
          },
          duration: {
            type: 'integer',
            description: 'Duration in milliseconds'
          },
          isrc: {
            type: 'string',
            nullable: true
          },
          platform: {
            type: 'string',
            enum: ['spotify', 'apple']
          },
          uri: {
            type: 'string',
            nullable: true
          },
          imageUrl: {
            type: 'string',
            nullable: true
          }
        }
      },
      ConversionRequest: {
        type: 'object',
        required: ['playlistId', 'playlistName', 'direction'],
        properties: {
          playlistId: {
            type: 'string'
          },
          playlistName: {
            type: 'string'
          },
          direction: {
            type: 'string',
            enum: ['spotify-to-apple', 'apple-to-spotify']
          }
        }
      },
      ConversionResult: {
        type: 'object',
        properties: {
          playlistId: {
            type: 'string'
          },
          playlistName: {
            type: 'string'
          },
          totalTracks: {
            type: 'integer'
          },
          successfulMatches: {
            type: 'integer'
          },
          failedMatches: {
            type: 'integer'
          },
          targetPlaylistId: {
            type: 'string',
            nullable: true
          },
          targetPlaylistUrl: {
            type: 'string',
            nullable: true
          },
          matches: {
            type: 'array',
            items: {
              $ref: '#/components/schemas/TrackMatch'
            }
          }
        }
      },
      TrackMatch: {
        type: 'object',
        properties: {
          sourceTrack: {
            $ref: '#/components/schemas/Track'
          },
          targetTrack: {
            nullable: true,
            allOf: [
              {
                $ref: '#/components/schemas/Track'
              }
            ]
          },
          confidence: {
            type: 'string',
            enum: ['high', 'medium', 'low', 'none']
          },
          matchType: {
            type: 'string',
            enum: ['isrc', 'search', 'manual'],
            nullable: true
          }
        }
      }
    },
    responses: {
      Unauthorized: {
        description: 'Authentication required',
        content: {
          'application/json': {
            schema: {
              type: 'object',
              properties: {
                error: {
                  type: 'string',
                  example: 'Please authenticate first'
                }
              }
            }
          }
        }
      },
      BadRequest: {
        description: 'Bad request',
        content: {
          'application/json': {
            schema: {
              type: 'object',
              properties: {
                error: {
                  type: 'string'
                }
              }
            }
          }
        }
      }
    },
    securitySchemes: {
      cookieAuth: {
        type: 'apiKey',
        in: 'cookie',
        name: 'session'
      }
    }
  }
};

export async function GET() {
  return NextResponse.json(openApiSpec);
}