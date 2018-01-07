import { TestBed, inject } from '@angular/core/testing';

import { MediumService } from './medium.service';

describe('MediumService', () => {
  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [MediumService]
    });
  });

  it('should be created', inject([MediumService], (service: MediumService) => {
    expect(service).toBeTruthy();
  }));
});
