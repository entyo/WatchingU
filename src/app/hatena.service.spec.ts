import { TestBed, inject } from '@angular/core/testing';

import { HatenaService } from './hatena.service';

describe('HatenaService', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [HatenaService]
    });
  });

  it('should be created', inject([HatenaService], (service: HatenaService) => {
    expect(service).toBeTruthy();
  }));
});
