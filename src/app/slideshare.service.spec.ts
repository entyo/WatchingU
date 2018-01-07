import { TestBed, inject } from '@angular/core/testing';

import { SlideShareService } from './slideshare.service';

describe('SlideShareService', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [SlideShareService]
    });
  });

  it('should be created', inject([SlideShareService], (service: SlideShareService) => {
    expect(service).toBeTruthy();
  }));
});
